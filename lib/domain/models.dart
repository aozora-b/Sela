import 'exceptions.dart';
import 'formats.dart';
import 'frame_naming.dart';

export 'formats.dart' show OutputFormat, OutputFormatX;

enum CaptureMode { interval, count, range }

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

  /// Effective average frame rate calculated from total frames and duration.
  double get effectiveFps {
    if (durationS > 0 && frameCount > 0) {
      return frameCount / durationS;
    }
    return fps > 0 ? fps : 30.0;
  }

  /// Formatted frame rate string for UI display (e.g. "24 FPS" or "24.2 FPS").
  String get formattedFps {
    final f = fps > 0 ? fps : effectiveFps;
    if ((f - f.roundToDouble()).abs() < 0.05) {
      return '${f.round()} FPS';
    }
    return '${f.toStringAsFixed(1)} FPS';
  }

  /// Maps playback time in seconds to the corresponding frame index (1..frameCount).
  int frameForTime(double timeS) {
    if (frameCount <= 1 || durationS <= 0) return 1;
    final clamped = timeS.clamp(0.0, durationS);
    final idx = ((clamped / durationS) * (frameCount - 1)).round() + 1;
    return idx.clamp(1, frameCount);
  }

  /// Maps a frame index (1..frameCount) to playback time in seconds.
  double timeForFrame(int frameIndex) {
    if (frameCount <= 1 || durationS <= 0) return 0.0;
    final clamped = frameIndex.clamp(1, frameCount);
    return ((clamped - 1) / (frameCount - 1)) * durationS;
  }
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
      throw const InvalidOptionException(
        'Waktu selesai harus lebih besar dari waktu mulai.',
      );
    }
    if ((mode == CaptureMode.interval || mode == CaptureMode.range) &&
        intervalS <= 0) {
      throw const InvalidOptionException(
        'Interval harus lebih besar dari 0 detik.',
      );
    }
    if (mode == CaptureMode.count && frameTotal < 1) {
      throw const InvalidOptionException('Jumlah frame harus minimal 1.');
    }
    if (quality < 1 || quality > 100) {
      throw const InvalidOptionException(
        'Kualitas JPG harus di antara 1 dan 100.',
      );
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
