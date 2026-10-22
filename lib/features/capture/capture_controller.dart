import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/gallery_name_registry.dart';
import '../../domain/frame_naming.dart';
import '../../domain/models.dart';
import '../../domain/sample_plan.dart';
import '../../engine/frame_engine_channel.dart';
import '../../engine/gallery_writer_channel.dart';
import '../progress/extraction_progress_controller.dart';
import 'capture_state.dart';

export 'capture_state.dart';

const int kMaxFrames = 200000;

class CaptureController extends Notifier<CaptureState> {
  final FrameEngineChannel _engine = FrameEngineChannel();
  final GalleryWriterChannel _gallery = GalleryWriterChannel();
  final Map<double, Uint8List> _thumbCache = {};
  static const int _maxThumbCache = 20;
  bool _isCancelled = false;

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
    } catch (_) {}
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

  Future<String?> saveCurrentFrame() async {
    final video = state.videoInfo;
    if (video == null) return null;

    final bytes = await _engine.getFrame(state.currentTime, exact: true);
    final registry = GalleryNameRegistry(_gallery);
    final stem = video.path.split(Platform.pathSeparator).last.split('.').first;
    final currentIdx = ((state.currentTime * video.fps).round() + 1).clamp(
      1,
      video.frameCount,
    );

    final rawName = buildName(
      stem: stem,
      index: currentIdx,
      ts: state.currentTime,
      ext: 'png',
      template: '{stem}_{index:06d}_{time}.{ext}',
    );
    final filename = await uniqueName(registry, rawName);
    final uri = await _gallery.writeImage(
      bytes: bytes,
      displayName: filename,
      mimeType: 'image/png',
    );
    registry.recordCreated(filename);

    final frames = Set<double>.from(state.savedFrames)..add(state.currentTime);
    state = state.copyWith(savedFrames: frames);
    return uri;
  }

  Future<void> startExtraction() async {
    final video = state.videoInfo;
    if (video == null) return;

    final opt = ExtractOptions(
      mode: CaptureMode.interval,
      intervalS: state.selectedInterval,
    );
    final points = planPoints(video, opt);

    if (points.length > kMaxFrames) {
      ref
          .read(extractionProgressProvider.notifier)
          .setError('Batas maksimum $kMaxFrames frame terlampaui.');
      return;
    }

    _isCancelled = false;
    final progressNotifier = ref.read(extractionProgressProvider.notifier);
    progressNotifier.start(points.length);

    final registry = GalleryNameRegistry(_gallery);
    final stem = video.path.split(Platform.pathSeparator).last.split('.').first;
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < points.length; i++) {
      if (_isCancelled) {
        progressNotifier.cancel(i);
        return;
      }

      final t = points[i];
      final bytes = await _engine.getFrame(t, exact: false);
      final rawName = buildName(
        stem: stem,
        index: i + 1,
        ts: t,
        ext: 'png',
        template: opt.template,
      );
      final filename = await uniqueName(registry, rawName);
      await _gallery.writeImage(
        bytes: bytes,
        displayName: filename,
        mimeType: 'image/png',
      );
      registry.recordCreated(filename);

      final elapsedMs = stopwatch.elapsedMilliseconds;
      final avgMsPerFrame = elapsedMs / (i + 1);
      final remainingMs = (avgMsPerFrame * (points.length - (i + 1))).round();

      progressNotifier.updateProgress(
        current: i + 1,
        remaining: Duration(milliseconds: remainingMs),
      );
    }

    progressNotifier.complete(points.length);
  }

  void cancelExtraction() {
    _isCancelled = true;
  }

  Future<bool> openGallery() => _gallery.openGallery();

  Future<Uint8List?> getThumbnail(double timeS) async {
    if (_thumbCache.containsKey(timeS)) return _thumbCache[timeS];
    try {
      final bytes = await _engine.getFrame(
        timeS,
        exact: false,
        width: 128,
        height: 128,
      );
      final list = Uint8List.fromList(bytes);
      if (_thumbCache.length >= _maxThumbCache) {
        _thumbCache.remove(_thumbCache.keys.first);
      }
      _thumbCache[timeS] = list;
      return list;
    } catch (_) {
      return null;
    }
  }
}

final captureProvider = NotifierProvider<CaptureController, CaptureState>(
  CaptureController.new,
);
