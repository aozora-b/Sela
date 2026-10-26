import 'package:flutter_test/flutter_test.dart';

import 'package:sela/domain/formats.dart';
import 'package:sela/domain/frame_naming.dart';
import 'package:sela/domain/models.dart';
import 'package:sela/domain/sample_plan.dart';

VideoInfo _info(double duration) => VideoInfo(
  path: 'video.mp4',
  durationS: duration,
  fps: 30,
  width: 1920,
  height: 1080,
  frameCount: (duration * 30).toInt(),
  codec: 'h264',
);

void main() {
  group('batas & konstanta publik', () {
    test('batas aman frame tepat 200000', () {
      expect(maxFrames, 200000);
    });

    test('panjang nama berkas dibatasi 180 karakter', () {
      final r = buildName(
        stem: 'x' * 400,
        index: 1,
        ts: 0,
        ext: 'png',
        template: '{stem}_{index:06d}_{time}.{ext}',
      );
      expect(r.length, lessThanOrEqualTo(180));
      expect(r.endsWith('.png'), isTrue);
    });

    test('indeks nama mulai dari 1 (bukan 0)', () {
      expect(
        () => buildName(
          stem: 'a',
          index: 0,
          ts: 0,
          ext: 'png',
          template: '{stem}_{index:06d}_{time}.{ext}',
        ),
        throwsArgumentError,
      );
    });
  });

  group('pemetaan format keluaran', () {
    test('png -> png/image-png/PNG', () {
      expect(OutputFormat.png.ext, 'png');
      expect(OutputFormat.png.mimeType, 'image/png');
      expect(OutputFormat.png.label, 'PNG');
    });

    test('jpeg -> jpg/image-jpeg/JPEG', () {
      expect(OutputFormat.jpeg.ext, 'jpg');
      expect(OutputFormat.jpeg.mimeType, 'image/jpeg');
      expect(OutputFormat.jpeg.label, 'JPEG');
    });
  });

  group('ekstensi video yang didukung', () {
    test('kumpulan ekstensi persis 9 jenis', () {
      expect(videoExtensions.length, 9);
      for (final e in [
        '.mp4',
        '.m4v',
        '.mkv',
        '.mov',
        '.webm',
        '.3gp',
        '.3g2',
        '.ts',
        '.m2ts',
      ]) {
        expect(videoExtensions.contains(e), isTrue, reason: 'harus memuat $e');
      }
    });

    test('deteksi ekstensi tidak peka huruf besar', () {
      expect(isVideoFile('a.MP4'), isTrue);
      expect(isVideoFile('b.Mov'), isTrue);
      expect(isVideoFile('c.txt'), isFalse);
    });
  });

  group('nama berkas: reserved & pemisah', () {
    test('seluruh nama reserved diberi awalan garis bawah', () {
      final reserved = <String>[
        'CON',
        'PRN',
        'AUX',
        'NUL',
        for (var i = 1; i <= 9; i++) 'COM$i',
        for (var i = 1; i <= 9; i++) 'LPT$i',
      ];
      for (final n in reserved) {
        expect(sanitizeStem(n).toUpperCase(), '_$n', reason: 'reserved: $n');
      }
    });

    test('pemisah waktu memakai strip (HH-MM-SS)', () {
      expect(formatTime(3661), '01-01-01');
      expect(formatTime(0), '00-00-00');
    });
  });

  group('planPoints — titik tidak pernah menyentuh akhir', () {
    test('interval 1 detik pada 10 detik = 10 titik, tanpa 10.0', () {
      final p = planPoints(
        _info(10),
        ExtractOptions(mode: CaptureMode.interval, intervalS: 1.0),
      );
      expect(p.length, 10);
      expect(p.first, 0.0);
      expect(p.last, 9.0);
      expect(p.contains(10.0), isFalse);
    });

    test('interval 0,5 detik pada 10 detik = 20 titik', () {
      final p = planPoints(
        _info(10),
        ExtractOptions(mode: CaptureMode.interval, intervalS: 0.5),
      );
      expect(p.length, 20);
      expect(p.last, closeTo(9.5, 1e-9));
    });
  });

  group('perkiraan ukuran keluaran (formula persis)', () {
    test('PNG memakai 0,40 byte/piksel', () {
      final bytes = estimateOutputBytes(
        _info(10),
        ExtractOptions(mode: CaptureMode.count),
        10,
      );
      expect(bytes, 8294400); // 10 * 1920 * 1080 * 0.40
    });

    test('JPEG q80 memakai 0,02 + 0,08 * (80/100) per piksel', () {
      final bytes = estimateOutputBytes(
        _info(10),
        ExtractOptions(
          mode: CaptureMode.count,
          fmt: OutputFormat.jpeg,
          quality: 80,
        ),
        10,
      );
      expect(bytes, 1741824); // 10 * 1920 * 1080 * 0.084
    });

    test('JPEG q100 memakai 0,10 byte/piksel', () {
      final bytes = estimateOutputBytes(
        _info(10),
        ExtractOptions(
          mode: CaptureMode.count,
          fmt: OutputFormat.jpeg,
          quality: 100,
        ),
        10,
      );
      expect(bytes, 2073600); // 10 * 1920 * 1080 * 0.10
    });
  });
}
