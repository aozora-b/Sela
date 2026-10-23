import 'dart:typed_data';

import '../../engine/frame_engine_channel.dart';

class ThumbnailCache {
  final Map<double, Uint8List> _cache = {};
  static const int _maxSize = 20;

  Future<Uint8List?> getThumbnail(
    FrameEngineChannel engine,
    double timeS,
  ) async {
    if (_cache.containsKey(timeS)) return _cache[timeS];
    try {
      final bytes = await engine.getFrame(
        timeS,
        exact: false,
        width: 128,
        height: 128,
      );
      final list = Uint8List.fromList(bytes);
      if (_cache.length >= _maxSize) {
        _cache.remove(_cache.keys.first);
      }
      return _cache[timeS] = list;
    } catch (_) {
      return null;
    }
  }
}
