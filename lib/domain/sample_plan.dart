import 'models.dart';
import 'exceptions.dart';

const int maxFrames = 200000;
const double _eps = 1e-9;

(double, double) _span(VideoInfo info, ExtractOptions opt) {
  final duration = info.durationS;
  if (!duration.isFinite || duration <= 0) {
    throw const PlanException(
      'Durasi video tidak terbaca, sehingga titik sampel tidak dapat dihitung.',
      advice: 'Coba berkas video lain atau periksa apakah berkas rusak.',
    );
  }

  final start = opt.startS.clamp(0.0, duration).toDouble();
  final end = opt.endS == null
      ? duration
      : opt.endS!.clamp(0.0, duration).toDouble();

  if (start >= duration - _eps) {
    throw PlanException(
      'Waktu mulai berada di luar durasi video.',
      advice:
          'Durasi video ini ${duration.toStringAsFixed(1)} detik; turunkan waktu mulai.',
    );
  }
  if (end - start <= _eps) {
    throw const PlanException(
      'Rentang waktu tidak menyisakan satu frame pun.',
      advice: 'Perlebar rentang waktu atau turunkan waktu mulai.',
    );
  }

  return (start, end);
}

List<double> planPoints(VideoInfo info, ExtractOptions opt) {
  final (start, end) = _span(info, opt);
  final span = end - start;

  List<double> times;

  if (opt.mode == CaptureMode.count) {
    final count = opt.frameTotal;
    if (count < 1) {
      throw const PlanException('Jumlah frame harus minimal 1.');
    }
    if (count > maxFrames) {
      throw PlanException(
        'Jumlah frame terlalu banyak ($count). Batas aman $maxFrames.',
        advice: 'Kurangi jumlah frame yang diminta.',
      );
    }
    final step = span / count;
    times = List.generate(count, (i) => start + i * step);
  } else {
    final interval = opt.intervalS;
    if (interval <= 0) {
      throw const PlanException('Interval harus lebih besar dari 0 detik.');
    }
    final count = ((span - _eps) / interval).floor() + 1;
    if (count > maxFrames) {
      throw PlanException(
        'Interval terlalu rapat: akan menghasilkan $count frame (batas $maxFrames).',
        advice: 'Perbesar interval atau perkecil rentang waktu.',
      );
    }
    times = List.generate(count, (i) => start + i * interval);
  }

  times = times.where((t) => t < end - _eps).toList();

  if (times.isEmpty) {
    throw const PlanException(
      'Tidak ada frame yang bisa diambil dengan setelan ini.',
      advice: 'Perlebar rentang waktu atau perkecil interval.',
    );
  }

  final result = <double>[];
  for (final t in times) {
    if (result.isEmpty || t > result.last + 1e-9) {
      result.add(double.parse(t.toStringAsFixed(6)));
    }
  }

  if (result.isEmpty) {
    throw const PlanException(
      'Tidak ada frame yang bisa diambil dengan setelan ini.',
    );
  }

  return result;
}

int estimateOutputBytes(VideoInfo info, ExtractOptions opt, int count) {
  final pixels = (info.width * info.height).clamp(1, double.infinity).toInt();
  final perPixel = opt.fmt == OutputFormat.png
      ? 0.40
      : 0.02 + 0.08 * (opt.quality / 100.0);
  final actualCount = count < 1 ? 1 : count;
  return (actualCount * pixels * perPixel).toInt();
}
