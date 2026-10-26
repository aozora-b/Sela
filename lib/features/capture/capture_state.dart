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
  final Set<int> markedFrames;
  final bool isScrubbing;
  final int thumbRevision;

  const CaptureState({
    this.videoInfo,
    this.currentTime = 0.0,
    this.isExactMode = true,
    this.selectedInterval = 0.25,
    this.activeFrame,
    this.savedFrames = const {},
    this.markedFrames = const {},
    this.isScrubbing = false,
    this.thumbRevision = 0,
  });

  CaptureState copyWith({
    VideoInfo? videoInfo,
    double? currentTime,
    bool? isExactMode,
    double? selectedInterval,
    Uint8List? activeFrame,
    Set<double>? savedFrames,
    Set<int>? markedFrames,
    bool? isScrubbing,
    int? thumbRevision,
  }) {
    return CaptureState(
      videoInfo: videoInfo ?? this.videoInfo,
      currentTime: currentTime ?? this.currentTime,
      isExactMode: isExactMode ?? this.isExactMode,
      selectedInterval: selectedInterval ?? this.selectedInterval,
      activeFrame: activeFrame ?? this.activeFrame,
      savedFrames: savedFrames ?? this.savedFrames,
      markedFrames: markedFrames ?? this.markedFrames,
      isScrubbing: isScrubbing ?? this.isScrubbing,
      thumbRevision: thumbRevision ?? this.thumbRevision,
    );
  }

  List<double> get intervalPoints {
    if (videoInfo == null || selectedInterval <= 0) return const [];
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

  int get estimatedFrameCount => intervalPoints.length;
}
