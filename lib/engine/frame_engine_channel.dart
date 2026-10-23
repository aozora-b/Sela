import 'package:flutter/services.dart';

import '../domain/models.dart';
import 'frame_engine.dart';

class FrameEngineChannel implements FrameEngine {
  static const MethodChannel _channel = MethodChannel('sela/frame_engine');
  int _instanceId = -1;
  static int _nextId = 0;

  @override
  Future<VideoInfo> open(String path) async {
    _instanceId = _nextId++;
    final res = await _channel.invokeMapMethod<String, dynamic>('open', {
      'id': _instanceId,
      'path': path,
    });
    final durationS = (res?['durationS'] as num?)?.toDouble() ?? 0.0;
    final fps = (res?['fps'] as num?)?.toDouble() ?? 30.0;
    final width = (res?['width'] as num?)?.toInt() ?? 1280;
    final height = (res?['height'] as num?)?.toInt() ?? 720;
    final frameCount =
        (res?['frameCount'] as num?)?.toInt() ?? (durationS * fps).round();
    final codec = (res?['codec'] as String?) ?? 'h264';

    return VideoInfo(
      path: path,
      durationS: durationS,
      fps: fps,
      width: width,
      height: height,
      frameCount: frameCount,
      codec: codec,
    );
  }

  @override
  Future<List<int>> getFrame(
    double timeS, {
    bool exact = false,
    int? width,
    int? height,
  }) async {
    if (_instanceId == -1) throw Exception("Engine not opened");
    final Map<String, dynamic> args = {
      'id': _instanceId,
      'timeMs': (timeS * 1000).toInt(),
      'exact': exact,
    };
    if (width != null) args['width'] = width;
    if (height != null) args['height'] = height;
    final res = await _channel.invokeMethod<dynamic>('getFrame', args);
    if (res == null) throw Exception("Frame extraction returned null");
    if (res is List) return res.cast<int>();
    throw Exception("Unexpected frame data type: ${res.runtimeType}");
  }

  @override
  Future<void> close() async {
    if (_instanceId != -1) {
      await _channel.invokeMethod('close', {'id': _instanceId});
      _instanceId = -1;
    }
  }
}
