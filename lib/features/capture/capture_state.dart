import 'dart:typed_data';

import '../../domain/models.dart';
import '../../domain/sample_plan.dart';

class CaptureState {
  final VideoInfo? videoInfo;
  final double currentTime;
  final bool isExactMode;
  final double selectedInterval;
  final Uint8List? activeFrame;
  final Set<double> savedFrames;

  const CaptureState({
    this.videoInfo,
    this.currentTime = 0.0,
    this.isExactMode = true,
    this.selectedInterval = 0.25,
    this.activeFrame,
    this.savedFrames = const {},
  });

  CaptureState copyWith({
    VideoInfo? videoInfo,
    double? currentTime,
    bool? isExactMode,
    double? selectedInterval,
    Uint8List? activeFrame,
    Set<double>? savedFrames,
  }) {
    return CaptureState(
      videoInfo: videoInfo ?? this.videoInfo,
      currentTime: currentTime ?? this.currentTime,
      isExactMode: isExactMode ?? this.isExactMode,
      selectedInterval: selectedInterval ?? this.selectedInterval,
      activeFrame: activeFrame ?? this.activeFrame,
      savedFrames: savedFrames ?? this.savedFrames,
    );
  }

  int get estimatedFrameCount {
    if (videoInfo == null || selectedInterval <= 0) return 0;
    final duration = videoInfo!.durationS;
    if (!duration.isFinite || duration <= 0) return 0;
    return ((duration - 1e-9) / selectedInterval).floor() + 1;
  }

  List<double> get intervalPoints {
    if (videoInfo == null || estimatedFrameCount > maxFrames) return const [];
    try {
      final opt = ExtractOptions(
        mode: CaptureMode.interval,
        intervalS: selectedInterval,
      );
      return planPoints(videoInfo!, opt);
    } catch (_) {
      return const [];
    }
  }

  String get estimatedSizeMb {
    if (videoInfo == null) return '0';
    try {
      final count = estimatedFrameCount;
      final opt = ExtractOptions(
        mode: CaptureMode.interval,
        intervalS: selectedInterval,
      );
      final bytes = estimateOutputBytes(videoInfo!, opt, count);
      final mb = bytes / (1024 * 1024);
      return mb.toStringAsFixed(1);
    } catch (e) {
      return '0';
    }
  }
}
