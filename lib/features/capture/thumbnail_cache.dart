import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/painting.dart';

import '../../domain/models.dart';
import '../../engine/frame_engine_channel.dart';

/// Cache LRU terpadu untuk strip pratinjau dan thumbnail filmstrip (Segmen C, D, E).
class ThumbnailCache {
  final Map<int, Uint8List> _cache = {};
  final Map<int, Future<Uint8List?>> _inFlight = {};
  static const int _maxSize = 120;
  int _sessionToken = 0;
  int _windowToken = 0;

  /// Membatasi ukuran ImageCache Flutter agar memori stabil di sesi panjang (Segmen E.3).
  static void trimImageCache({int maxEntries = 60, int maxBytes = 24 << 20}) {
    try {
      final c = PaintingBinding.instance.imageCache;
      c.maximumSize = maxEntries;
      c.maximumSizeBytes = maxBytes;
    } catch (_) {}
  }

  /// Mengosongkan ImageCache Flutter saat keluar/berganti video (Segmen E.2).
  static void flushImageCache() {
    try {
      final c = PaintingBinding.instance.imageCache;
      c.clear();
      c.clearLiveImages();
    } catch (_) {}
  }

  /// Mengambil thumbnail yang persis ada di cache (0 ms) dan memperbarui urutan LRU.
  Uint8List? getCached(int frameIndex) {
    final val = _cache.remove(frameIndex);
    if (val != null) {
      _cache[frameIndex] = val;
    }
    return val;
  }

  /// Mengambil placeholder terdekat dari strip/cache dalam 0 ms (Segmen D.1).
  Uint8List? getNearestCached(int frameIndex) {
    final exact = getCached(frameIndex);
    if (exact != null) return exact;
    if (_cache.isEmpty) return null;

    int? bestKey;
    int bestDist = 1 << 30;
    for (final k in _cache.keys) {
      final d = (k - frameIndex).abs();
      if (d < bestDist) {
        bestDist = d;
        bestKey = k;
      }
    }
    return bestKey != null ? _cache[bestKey] : null;
  }

  void _putCache(int frameIndex, Uint8List bytes) {
    _cache.remove(frameIndex);
    if (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[frameIndex] = bytes;
  }

  void cancelPendingWindow() {
    _windowToken++;
    _inFlight.clear();
  }

  void clear() {
    _sessionToken++;
    _windowToken++;
    _cache.clear();
    _inFlight.clear();
  }

  Future<Uint8List?> getThumbnail(
    FrameEngineChannel engine,
    int frameIndex,
    double timeS, {
    bool exact = true,
  }) {
    final existing = getCached(frameIndex);
    if (existing != null) return Future.value(existing);

    final pending = _inFlight[frameIndex];
    if (pending != null) return pending;

    final future = _fetch(engine, frameIndex, timeS, exact: exact);
    _inFlight[frameIndex] = future;
    return future;
  }

  Future<Uint8List?> _fetch(
    FrameEngineChannel engine,
    int frameIndex,
    double timeS, {
    required bool exact,
  }) async {
    final mySession = _sessionToken;
    try {
      final bytes = await engine.getFrame(
        timeS,
        exact: exact,
        width: 140,
        height: 100,
        quality: exact ? 72 : 60,
      );
      if (mySession != _sessionToken || bytes.isEmpty) return null;
      final list = Uint8List.fromList(bytes);
      _putCache(frameIndex, list);
      return list;
    } catch (_) {
      return null;
    } finally {
      _inFlight.remove(frameIndex)?.ignore();
    }
  }

  /// Prefetch tetangga di sekitar posisi saat ini (Segmen D.2: +1, -1, +2, -2, +3, -3).
  Future<void> prefetchNeighbours({
    required FrameEngineChannel engine,
    required VideoInfo info,
    required int centerFrame,
    required void Function() onUpdated,
  }) async {
    final mySession = _sessionToken;
    final myWindow = ++_windowToken;
    const offsets = [0, 1, -1, 2, -2, 3, -3];

    for (final d in offsets) {
      if (mySession != _sessionToken || myWindow != _windowToken) return;
      final idx = (centerFrame + d).clamp(1, info.frameCount);
      if (_cache.containsKey(idx)) continue;
      final t = info.timeForFrame(idx);
      final res = await getThumbnail(engine, idx, t, exact: true);
      if (mySession != _sessionToken || myWindow != _windowToken) return;
      if (res != null) onUpdated();
    }
  }

  /// Membangun strip kasar sekali saat video dibuka agar placeholder 0 ms selalu siap (Segmen C.1).
  Future<void> warmUpStrip({
    required FrameEngineChannel engine,
    required VideoInfo info,
    required void Function() onUpdated,
  }) async {
    final mySession = _sessionToken;
    final total = info.frameCount;
    if (total <= 0) return;
    final step = (total / 20).ceil().clamp(1, total);

    for (int idx = 1; idx <= total; idx += step) {
      if (mySession != _sessionToken) return;
      if (_cache.containsKey(idx)) continue;
      final t = info.timeForFrame(idx);
      final res = await _fetch(engine, idx, t, exact: false);
      if (mySession != _sessionToken) return;
      if (res != null) onUpdated();
    }
  }
}
