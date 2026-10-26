import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models.dart';
import '../../engine/frame_engine_channel.dart';
import '../../engine/gallery_writer_channel.dart';
import '../history/history_repository.dart';
import '../settings/settings_controller.dart';
import 'capture_state.dart';
import 'extraction_runner.dart';
import 'frame_saver.dart';
import 'thumbnail_cache.dart';
export 'capture_state.dart';

class CaptureController extends Notifier<CaptureState> {
  final _engine = FrameEngineChannel();
  final _gallery = GalleryWriterChannel();
  final _thumbs = ThumbnailCache();
  final _previewMemCache = <int, Uint8List>{};
  late final _saver = FrameSaver(engine: _engine, gallery: _gallery);
  late final _history = ref.read(historyRepositoryProvider);
  late final _runner = ExtractionRunner(
    ref: ref, engine: _engine, gallery: _gallery, history: _history,
  );
  int _fetchSeq = 0;
  bool _isFetching = false;
  double? _pendingTimeS;
  bool? _pendingExact;
  Timer? _debounceExactTimer;

  @override
  CaptureState build() {
    ref.onDispose(() {
      _debounceExactTimer?.cancel();
      _thumbs.clear();
      _previewMemCache.clear();
      ThumbnailCache.flushImageCache();
      _engine.close();
    });
    return const CaptureState();
  }

  void _bumpThumb() =>
      state = state.copyWith(thumbRevision: state.thumbRevision + 1);

  Future<void> openVideo(String path, [VideoInfo? info]) async {
    _debounceExactTimer?.cancel();
    _isFetching = false;
    _pendingTimeS = null;
    _pendingExact = null;
    _thumbs.clear();
    _previewMemCache.clear();
    ThumbnailCache.trimImageCache();
    ThumbnailCache.flushImageCache();

    final meta = await _engine.open(path);
    final v = info ?? meta;
    state = CaptureState(
      videoInfo: v,
      currentTime: 0.0,
      isExactMode: state.isExactMode,
      selectedInterval: state.selectedInterval,
    );
    await fetchActiveFrame(0.0, exact: true);
    _prefetch(v, 1);
    unawaited(_thumbs.warmUpStrip(engine: _engine, info: v, onUpdated: _bumpThumb));
  }

  void _prefetch(VideoInfo v, int centerFrame) {
    unawaited(_thumbs.prefetchNeighbours(
      engine: _engine, info: v, centerFrame: centerFrame, onUpdated: _bumpThumb,
    ));
  }

  Future<void> fetchActiveFrame(double timeS, {bool? exact}) async {
    final isExact = exact ?? state.isExactMode;
    final bucket = (timeS * 20).round();
    if (!isExact && _previewMemCache.containsKey(bucket)) {
      state = state.copyWith(activeFrame: _previewMemCache[bucket]);
      return;
    }
    if (_isFetching) {
      _pendingTimeS = timeS;
      _pendingExact = exact;
      return;
    }
    _isFetching = true;
    final currentSeq = ++_fetchSeq;
    final info = state.videoInfo;
    final maxDim = isExact ? 540 : 320;
    int? pw, ph;
    if (info != null && info.width > 0 && info.height > 0) {
      final isWide = info.width >= info.height;
      pw = isWide ? maxDim : (maxDim * info.width / info.height).round();
      ph = isWide ? (maxDim * info.height / info.width).round() : maxDim;
    }
    try {
      final bytes = await _engine.getFrame(
        timeS, exact: isExact, width: pw, height: ph, quality: isExact ? 82 : 50,
      );
      if (_fetchSeq == currentSeq && bytes.isNotEmpty) {
        final u8 = Uint8List.fromList(bytes);
        if (_previewMemCache.length >= 60) _previewMemCache.remove(_previewMemCache.keys.first);
        _previewMemCache[bucket] = u8;
        state = state.copyWith(activeFrame: u8);
      }
    } catch (_) {
    } finally {
      _isFetching = false;
      if (_pendingTimeS != null) {
        final pt = _pendingTimeS!;
        final pe = _pendingExact;
        _pendingTimeS = null;
        _pendingExact = null;
        unawaited(fetchActiveFrame(pt, exact: pe));
      }
    }
  }

  void seekTo(double timeS, {bool? exact}) {
    final v = state.videoInfo;
    if (v == null) return;
    final clamped = timeS.clamp(0.0, v.durationS);
    if ((state.currentTime - clamped).abs() <= 0.0005) return;

    state = state.copyWith(currentTime: clamped);
    if (state.isScrubbing) {
      _thumbs.cancelPendingWindow();
      fetchActiveFrame(clamped, exact: false);
      return;
    }

    final wantExact = exact ?? state.isExactMode;
    fetchActiveFrame(clamped, exact: wantExact);
    _debounceExactTimer?.cancel();
    _debounceExactTimer = Timer(const Duration(milliseconds: 90), () {
      final curV = state.videoInfo;
      if (curV == null || state.isScrubbing) return;
      if (state.isExactMode && !wantExact) fetchActiveFrame(state.currentTime, exact: true);
      _prefetch(curV, curV.frameForTime(state.currentTime));
    });
  }

  void setScrubbing(bool scrubbing) {
    if (state.isScrubbing == scrubbing) return;
    state = state.copyWith(isScrubbing: scrubbing);
    final v = state.videoInfo;
    if (v == null) return;
    _debounceExactTimer?.cancel();
    if (scrubbing) {
      _thumbs.cancelPendingWindow();
    } else {
      fetchActiveFrame(state.currentTime, exact: state.isExactMode);
      _prefetch(v, v.frameForTime(state.currentTime));
    }
  }

  void toggleMode(bool exact) {
    state = state.copyWith(isExactMode: exact);
    fetchActiveFrame(state.currentTime, exact: exact);
    if (exact && state.videoInfo != null) {
      _prefetch(state.videoInfo!, state.videoInfo!.frameForTime(state.currentTime));
    }
  }

  void selectInterval(double intervalS) => state = state.copyWith(selectedInterval: intervalS);

  void toggleMarkCurrentFrame() {
    final v = state.videoInfo;
    if (v != null) toggleMarkFrame(v.frameForTime(state.currentTime));
  }

  void toggleMarkFrame(int frameIndex) {
    final updated = Set<int>.from(state.markedFrames);
    if (!updated.remove(frameIndex)) updated.add(frameIndex);
    state = state.copyWith(markedFrames: updated);
  }

  Future<String?> saveCurrentFrame() async {
    final v = state.videoInfo;
    if (v == null) return null;
    final uri = await _saver.saveSingle(
      video: v, timeS: state.currentTime, settings: ref.read(settingsProvider),
    );
    if (uri != null) state = state.copyWith(savedFrames: {...state.savedFrames, state.currentTime});
    return uri;
  }

  Future<List<String>> saveAllMarkedFrames() async {
    final v = state.videoInfo;
    if (v == null || state.markedFrames.isEmpty) return [];
    final indices = state.markedFrames.toList()..sort();
    final uris = await _runner.saveMarked(v, state.markedFrames);
    state = state.copyWith(
      markedFrames: {}, savedFrames: {...state.savedFrames, ...indices.map(v.timeForFrame)},
    );
    return uris;
  }

  Future<void> startExtraction({required String errorMessage, int resumeFromIndex = 0}) async {
    final v = state.videoInfo;
    if (v != null) {
      await _runner.run(
        videoInfo: v, intervalS: state.selectedInterval, errorMessage: errorMessage, resumeFromIndex: resumeFromIndex,
      );
    }
  }

  void cancelExtraction() => _runner.cancel();
  Future<bool> openGallery() => _gallery.openGallery();
  Uint8List? getCachedThumbnail(int frameIndex) => _thumbs.getCached(frameIndex);
  Uint8List? getNearestThumbnail(int frameIndex) => _thumbs.getNearestCached(frameIndex);
  Future<Uint8List?> getThumbnail(int frameIndex, double timeS) =>
      _thumbs.getThumbnail(_engine, frameIndex, timeS);
}

final captureProvider = NotifierProvider<CaptureController, CaptureState>(CaptureController.new);
