import 'exceptions.dart';
import 'frame_naming.dart';

enum CaptureMode { interval, count, range }

enum OutputFormat { png, jpg }

class VideoInfo {
  final String path;
  final double durationS;
  final double fps;
  final int width;
  final int height;
  final int frameCount;
  final String codec;
  final List<String> warnings;

  const VideoInfo({
    required this.path,
    required this.durationS,
    required this.fps,
    required this.width,
    required this.height,
    required this.frameCount,
    required this.codec,
    this.warnings = const [],
  });

  String get resolution => '$width×$height';
}

class ExtractOptions {
  final CaptureMode mode;
  final double intervalS;
  final int frameTotal;
  final double startS;
  final double? endS;
  final OutputFormat fmt;
  final int quality;
  final String? outDir;
  final String template;

  const ExtractOptions._({
    required this.mode,
    required this.intervalS,
    required this.frameTotal,
    required this.startS,
    this.endS,
    required this.fmt,
    required this.quality,
    this.outDir,
    required this.template,
  });

  factory ExtractOptions({
    required CaptureMode mode,
    double intervalS = 1.0,
    int frameTotal = 30,
    double startS = 0.0,
    double? endS,
    OutputFormat fmt = OutputFormat.png,
    int quality = 95,
    String? outDir,
    String template = '{stem}_{index:06d}_{time}.{ext}',
  }) {
    if (startS < 0) {
      throw const InvalidOptionException('Waktu mulai tidak boleh negatif.');
    }
    if (endS != null && endS <= startS) {
      throw const InvalidOptionException('Waktu selesai harus lebih besar dari waktu mulai.');
    }
    if ((mode == CaptureMode.interval || mode == CaptureMode.range) && intervalS <= 0) {
      throw const InvalidOptionException('Interval harus lebih besar dari 0 detik.');
    }
    if (mode == CaptureMode.count && frameTotal < 1) {
      throw const InvalidOptionException('Jumlah frame harus minimal 1.');
    }
    if (quality < 1 || quality > 100) {
      throw const InvalidOptionException('Kualitas JPG harus di antara 1 dan 100.');
    }

    validateTemplate(template);

    return ExtractOptions._(
      mode: mode,
      intervalS: intervalS,
      frameTotal: frameTotal,
      startS: startS,
      endS: endS,
      fmt: fmt,
      quality: quality,
      outDir: outDir,
      template: template,
    );
  }
}

class FrameResult {
  final String path;
  final double timestampS;
  final int index;
  final int sizeBytes;

  const FrameResult({
    required this.path,
    required this.timestampS,
    required this.index,
    required this.sizeBytes,
  });
}
