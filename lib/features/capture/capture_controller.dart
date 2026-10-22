import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models.dart';
import '../../domain/sample_plan.dart';
import '../../engine/frame_engine_channel.dart';

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

  List<double> get intervalPoints {
    if (videoInfo == null) return const [];
    try {
      final opt = ExtractOptions(
        mode: CaptureMode.interval,
        intervalS: selectedInterval,
      );
      return planPoints(videoInfo!, opt);
    } catch (e) {
      return const [];
    }
  }

  int get estimatedFrameCount => intervalPoints.length;

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

class CaptureController extends Notifier<CaptureState> {
  final FrameEngineChannel _engine = FrameEngineChannel();
  final Map<double, Uint8List> _thumbCache = {};
  static const int _maxThumbCache = 20;

  @override
  CaptureState build() {
    ref.onDispose(() => _engine.close());
    return const CaptureState();
  }

  Future<void> openVideo(String path, [VideoInfo? info]) async {
    final meta = info ?? await _engine.open(path);
    state = state.copyWith(videoInfo: meta, currentTime: 0.0);
    await fetchActiveFrame(0.0);
  }

  Future<void> fetchActiveFrame(double timeS) async {
    try {
      final bytes = await _engine.getFrame(timeS, exact: state.isExactMode);
      state = state.copyWith(activeFrame: Uint8List.fromList(bytes));
    } catch (e) {
      // Ignored for spike
    }
  }

  void seekTo(double timeS) {
    if (state.videoInfo == null) return;
    final clamped = timeS.clamp(0.0, state.videoInfo!.durationS);
    if ((state.currentTime - clamped).abs() > 0.001) {
      state = state.copyWith(currentTime: clamped);
      fetchActiveFrame(clamped);
    }
  }

  void toggleMode(bool exact) {
    state = state.copyWith(isExactMode: exact);
    fetchActiveFrame(state.currentTime);
  }

  void selectInterval(double intervalS) {
    state = state.copyWith(selectedInterval: intervalS);
  }

  void saveCurrentFrame() {
    final frames = Set<double>.from(state.savedFrames)..add(state.currentTime);
    state = state.copyWith(savedFrames: frames);
  }

  Future<Uint8List?> getThumbnail(double timeS) async {
    if (_thumbCache.containsKey(timeS)) {
      return _thumbCache[timeS];
    }
    try {
      final bytes = await _engine.getFrame(
        timeS,
        exact: false, // OPTION_CLOSEST_SYNC for thumbnails
        width: 128,
        height: 128,
      );
      final list = Uint8List.fromList(bytes);

      if (_thumbCache.length >= _maxThumbCache) {
        _thumbCache.remove(_thumbCache.keys.first);
      }
      _thumbCache[timeS] = list;
      return list;
    } catch (e) {
      return null;
    }
  }
}

final captureProvider = NotifierProvider<CaptureController, CaptureState>(
  CaptureController.new,
);
