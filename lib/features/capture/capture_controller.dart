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
import '../history/history_repository.dart';
import '../progress/extraction_progress_controller.dart';
import 'capture_state.dart';
import 'thumbnail_cache.dart';
export 'capture_state.dart';

class CaptureController extends Notifier<CaptureState> {
  final _engine = FrameEngineChannel();
  final _gallery = GalleryWriterChannel();
  final _thumbs = ThumbnailCache();
  late final _history = ref.read(historyRepositoryProvider);
  bool _isCancelled = false;

  @override
  CaptureState build() {
    ref.onDispose(() => _engine.close());
    return const CaptureState();
  }

  Future<void> openVideo(String path, [VideoInfo? info]) async {
    final meta = await _engine.open(path);
    state = state.copyWith(videoInfo: info ?? meta, currentTime: 0.0);
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
      final name = await uniqueName(GalleryNameRegistry(_gallery), raw);
      final uri = await _gallery.writeImage(
        bytes: bytes,
        displayName: name,
        mimeType: 'image/png',
      );
      GalleryNameRegistry(_gallery).recordCreated(name);
      state = state.copyWith(
        savedFrames: {...state.savedFrames, state.currentTime},
      );
      return uri;
    } catch (_) {
      return null;
    }
  }

  Future<void> startExtraction({
    required String errorMessage,
    int resumeFromIndex = 0,
  }) async {
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
    final remCount = points.length - resumeFromIndex;
    progress.start(
      points.length,
      initialCurrent: resumeFromIndex,
      initialRemaining: Duration(milliseconds: remCount * 300),
    );
    final registry = GalleryNameRegistry(_gallery);
    final stem = _stem(video.path);
    final sw = Stopwatch()..start();
    int totalBytes = 0;

    try {
      for (int i = resumeFromIndex; i < points.length; i++) {
        if (_isCancelled) {
          progress.cancel(i);
          return;
        }
        final t = points[i];
        final bytes = await _engine.getFrame(t, exact: true);
        totalBytes += bytes.length;
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
        await _history.recordProgress(
          videoPath: video.path,
          savedCount: i + 1,
          total: points.length,
          totalBytes: totalBytes,
        );

        final avgMs = sw.elapsedMilliseconds / ((i - resumeFromIndex) + 1);
        final remMs = (avgMs * (points.length - (i + 1))).round();
        progress.updateProgress(
          current: i + 1,
          remaining: Duration(milliseconds: remMs),
        );
      }
      await _history.recordCompleted(
        videoPath: video.path,
        total: points.length,
        totalBytes: totalBytes,
      );
      progress.complete(points.length);
    } on OutputNotWritableException catch (e) {
      progress.setError(e.message);
    } catch (e) {
      progress.setError(e.toString());
    }
  }

  void cancelExtraction() => _isCancelled = true;

  Future<bool> openGallery() => _gallery.openGallery();

  Future<Uint8List?> getThumbnail(double timeS) =>
      _thumbs.getThumbnail(_engine, timeS);
}

final captureProvider = NotifierProvider<CaptureController, CaptureState>(
  CaptureController.new,
);
