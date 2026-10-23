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
import '../settings/settings_controller.dart';
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
    final v = state.videoInfo;
    if (v == null) return null;
    final s = ref.read(settingsProvider);
    try {
      final bytes = await _engine.getFrame(
        state.currentTime,
        exact: true,
        format: s.format.name,
        quality: s.jpegQuality,
      );
      final idx = ((state.currentTime * v.fps).round() + 1).clamp(
        1,
        v.frameCount,
      );
      final raw = buildName(
        stem: _stem(v.path),
        index: idx,
        ts: state.currentTime,
        ext: s.format.ext,
        template: '{stem}_{index:06d}_{time}.{ext}',
      );
      final name = await uniqueName(GalleryNameRegistry(_gallery), raw);
      final uri = await _gallery.writeImage(
        bytes: bytes,
        displayName: name,
        mimeType: s.format.mimeType,
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
    final v = state.videoInfo;
    if (v == null) return;
    final s = ref.read(settingsProvider);
    final progress = ref.read(extractionProgressProvider.notifier);
    final opt = ExtractOptions(
      mode: CaptureMode.interval,
      intervalS: state.selectedInterval,
      fmt: s.format,
      quality: s.jpegQuality,
    );
    final List<double> pts;
    try {
      pts = planPoints(v, opt);
    } catch (_) {
      return progress.setError(errorMessage);
    }
    if (pts.length > maxFrames) return progress.setError(errorMessage);

    _isCancelled = false;
    final rem = pts.length - resumeFromIndex;
    progress.start(
      pts.length,
      initialCurrent: resumeFromIndex,
      initialRemaining: Duration(milliseconds: rem * 300),
    );
    final reg = GalleryNameRegistry(_gallery);
    final stem = _stem(v.path);
    final sw = Stopwatch()..start();
    int totalBytes = 0;

    try {
      for (int i = resumeFromIndex; i < pts.length; i++) {
        if (_isCancelled) return progress.cancel(i);
        final t = pts[i];
        final bytes = await _engine.getFrame(
          t,
          exact: false,
          format: s.format.name,
          quality: s.jpegQuality,
        );
        totalBytes += bytes.length;
        final raw = buildName(
          stem: stem,
          index: i + 1,
          ts: t,
          ext: s.format.ext,
          template: opt.template,
        );
        final name = await uniqueName(reg, raw);
        await _gallery.writeImage(
          bytes: bytes,
          displayName: name,
          mimeType: s.format.mimeType,
        );
        reg.recordCreated(name);
        if ((i + 1) % 5 == 0 || i + 1 == pts.length) {
          await _history.recordProgress(
            videoPath: v.path,
            savedCount: i + 1,
            total: pts.length,
            totalBytes: totalBytes,
          );
        }
        final avg = sw.elapsedMilliseconds / ((i - resumeFromIndex) + 1);
        final remMs = (avg * (pts.length - (i + 1))).round();
        progress.updateProgress(
          current: i + 1,
          remaining: Duration(milliseconds: remMs),
        );
      }
      await _history.recordCompleted(
        videoPath: v.path,
        total: pts.length,
        totalBytes: totalBytes,
      );
      progress.complete(pts.length);
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
