import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/gallery_name_registry.dart';
import '../../domain/exceptions.dart';
import '../../domain/frame_naming.dart';
import '../../domain/models.dart';
import '../../domain/sample_plan.dart';
import '../../engine/frame_engine_channel.dart';
import '../../engine/gallery_writer_channel.dart';
import '../progress/extraction_progress_controller.dart';
import 'capture_state.dart';
export 'capture_state.dart';

class CaptureController extends Notifier<CaptureState> {
  final _engine = FrameEngineChannel();
  final _gallery = GalleryWriterChannel();
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

  void selectInterval(double intervalS) =>
      state = state.copyWith(selectedInterval: intervalS);

  String _stem(String path) =>
      path.split(Platform.pathSeparator).last.split('.').first;

  Future<String?> saveCurrentFrame() async {
    final video = state.videoInfo;
    if (video == null) return null;
    try {
      final bytes = await _engine.getFrame(state.currentTime, exact: true);
      final registry = GalleryNameRegistry(_gallery);
      final idx = ((state.currentTime * video.fps).round() + 1).clamp(
        1,
        video.frameCount,
      );
      final raw = buildName(
        stem: _stem(video.path),
        index: idx,
        ts: state.currentTime,
        ext: 'png',
        template: '{stem}_{index:06d}_{time}.{ext}',
      );
      final name = await uniqueName(registry, raw);
      final uri = await _gallery.writeImage(
        bytes: bytes,
        displayName: name,
        mimeType: 'image/png',
      );
      registry.recordCreated(name);
      state = state.copyWith(
        savedFrames: {...state.savedFrames, state.currentTime},
      );
      return uri;
    } on OutputNotWritableException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> startExtraction({required String errorMessage}) async {
    final video = state.videoInfo;
    if (video == null) return;
    final progress = ref.read(extractionProgressProvider.notifier);
    final opt = ExtractOptions(
      mode: CaptureMode.interval,
      intervalS: state.selectedInterval,
    );
    final List<double> points;
    try {
      points = planPoints(video, opt);
    } catch (_) {
      progress.setError(errorMessage);
      return;
    }
    if (points.length > maxFrames) {
      progress.setError(errorMessage);
      return;
    }

    _isCancelled = false;
    progress.start(points.length);
    final registry = GalleryNameRegistry(_gallery);
    final stem = _stem(video.path);
    final sw = Stopwatch()..start();

    try {
      for (int i = 0; i < points.length; i++) {
        if (_isCancelled) {
          progress.cancel(i);
          return;
        }
        final t = points[i];
        final bytes = await _engine.getFrame(t, exact: true);
        final raw = buildName(
          stem: stem,
          index: i + 1,
          ts: t,
          ext: 'png',
          template: opt.template,
        );
        final name = await uniqueName(registry, raw);
        await _gallery.writeImage(
          bytes: bytes,
          displayName: name,
          mimeType: 'image/png',
        );
        registry.recordCreated(name);

        final avgMs = sw.elapsedMilliseconds / (i + 1);
        final remMs = (avgMs * (points.length - (i + 1))).round();
        progress.updateProgress(
          current: i + 1,
          remaining: Duration(milliseconds: remMs),
        );
      }
      progress.complete(points.length);
    } on OutputNotWritableException catch (e) {
      progress.setError(e.message);
    } catch (e) {
      progress.setError(e.toString());
    }
  }

  void cancelExtraction() => _isCancelled = true;

  Future<bool> openGallery() => _gallery.openGallery();

  Future<Uint8List?> getThumbnail(double timeS) async {
    if (_thumbCache.containsKey(timeS)) return _thumbCache[timeS];
    try {
      final b = await _engine.getFrame(
        timeS,
        exact: false,
        width: 128,
        height: 128,
      );
      final list = Uint8List.fromList(b);
      if (_thumbCache.length >= _maxThumbCache) {
        _thumbCache.remove(_thumbCache.keys.first);
      }
      return _thumbCache[timeS] = list;
    } catch (_) {
      return null;
    }
  }
}

final captureProvider = NotifierProvider<CaptureController, CaptureState>(
  CaptureController.new,
);
