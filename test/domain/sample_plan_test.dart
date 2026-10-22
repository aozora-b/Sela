import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/models.dart';
import 'package:sela/domain/sample_plan.dart';
import 'package:sela/domain/exceptions.dart';

VideoInfo info(double duration) => VideoInfo(
  path: 'video.mp4',
  durationS: duration,
  fps: 30,
  width: 1920,
  height: 1080,
  frameCount: (duration * 30).toInt(),
  codec: 'h264',
);

void main() {
  group('mode interval', () {
    test('1 detik pada video 60 detik menghasilkan 60 titik', () {
      final p = planPoints(
        info(60),
        ExtractOptions(mode: CaptureMode.interval, intervalS: 1.0),
      );
      expect(p.length, 60);
      expect(p.first, 0.0);
      expect(p.last, 59.0);
      expect(p, orderedEquals([...p]..sort()));
    });

    test('3 detik pada video 10 detik', () {
      final p = planPoints(
        info(10),
        ExtractOptions(mode: CaptureMode.interval, intervalS: 3.0),
      );
      expect(p, [0.0, 3.0, 6.0, 9.0]);
    });

    test('menghormati start dan end', () {
      final p = planPoints(
        info(60),
        ExtractOptions(
          mode: CaptureMode.interval,
          intervalS: 1.0,
          startS: 10,
          endS: 20,
        ),
      );
      expect(p.length, 10);
      expect(p.first, 10.0);
      expect(p.last, 19.0);
    });

    test('interval lebih kecil dari durasi frame', () {
      final p = planPoints(
        info(10),
        ExtractOptions(mode: CaptureMode.interval, intervalS: 0.25),
      );
      expect(p.length, 40);
      expect(p.last, closeTo(9.75, 1e-9));
    });
  });

  group('mode count', () {
    test('30 frame tersebar merata pada 60 detik', () {
      final p = planPoints(
        info(60),
        ExtractOptions(mode: CaptureMode.count, frameTotal: 30),
      );
      expect(p.length, 30);
      final gaps = [for (var i = 1; i < p.length; i++) p[i] - p[i - 1]];
      expect(
        gaps.reduce((a, b) => a > b ? a : b) -
            gaps.reduce((a, b) => a < b ? a : b),
        lessThan(1e-9),
      );
      expect(p.first, 0.0);
      expect(p.last, lessThan(60.0));
      expect(p.last, closeTo(58.0, 1e-9));
    });

    test('satu frame', () {
      final p = planPoints(
        info(10),
        ExtractOptions(mode: CaptureMode.count, frameTotal: 1),
      );
      expect(p, [0.0]);
    });

    test('menghormati rentang', () {
      final p = planPoints(
        info(100),
        ExtractOptions(
          mode: CaptureMode.count,
          frameTotal: 5,
          startS: 20,
          endS: 30,
        ),
      );
      expect(p.length, 5);
      expect(p.first, 20.0);
      expect(p.last, closeTo(28.0, 1e-9));
    });
  });

  group('mode range', () {
    test('menghormati batas', () {
      final p = planPoints(
        info(60),
        ExtractOptions(
          mode: CaptureMode.range,
          intervalS: 2.0,
          startS: 10,
          endS: 20,
        ),
      );
      expect(p, [10.0, 12.0, 14.0, 16.0, 18.0]);
    });

    test('tanpa end memakai seluruh durasi', () {
      final p = planPoints(
        info(5),
        ExtractOptions(mode: CaptureMode.range, intervalS: 1.0),
      );
      expect(p, [0.0, 1.0, 2.0, 3.0, 4.0]);
    });

    test('end di-clamp ke durasi', () {
      final p = planPoints(
        info(10),
        ExtractOptions(
          mode: CaptureMode.range,
          intervalS: 2.0,
          startS: 5,
          endS: 99,
        ),
      );
      expect(p, [5.0, 7.0, 9.0]);
    });
  });

  group('galat', () {
    test('start di luar durasi', () {
      expect(
        () => planPoints(
          info(10),
          ExtractOptions(mode: CaptureMode.interval, startS: 20),
        ),
        throwsA(isA<PlanException>()),
      );
    });

    test('durasi nol', () {
      expect(
        () => planPoints(info(0), ExtractOptions(mode: CaptureMode.interval)),
        throwsA(isA<PlanException>()),
      );
    });

    test('terlalu banyak frame', () {
      expect(
        () => planPoints(
          info(10000),
          ExtractOptions(mode: CaptureMode.count, frameTotal: 250000),
        ),
        throwsA(isA<PlanException>()),
      );
    });
  });

  group('validasi opsi', () {
    test('nilai tidak sah ditolak', () {
      expect(
        () => ExtractOptions(mode: CaptureMode.interval, intervalS: 0),
        throwsA(isA<InvalidOptionException>()),
      );
      expect(
        () => ExtractOptions(mode: CaptureMode.count, frameTotal: 0),
        throwsA(isA<InvalidOptionException>()),
      );
      expect(
        () => ExtractOptions(mode: CaptureMode.interval, quality: 0),
        throwsA(isA<InvalidOptionException>()),
      );
      expect(
        () => ExtractOptions(mode: CaptureMode.interval, startS: 5, endS: 5),
        throwsA(isA<InvalidOptionException>()),
      );
    });
  });

  test('perkiraan PNG lebih besar dari JPG', () {
    final i = info(10);
    final png = estimateOutputBytes(
      i,
      ExtractOptions(mode: CaptureMode.count),
      10,
    );
    final jpg = estimateOutputBytes(
      i,
      ExtractOptions(
        mode: CaptureMode.count,
        fmt: OutputFormat.jpg,
        quality: 80,
      ),
      10,
    );
    expect(png, greaterThan(jpg));
    expect(jpg, greaterThan(0));
  });
}
