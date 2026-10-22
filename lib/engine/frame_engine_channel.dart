import 'package:flutter/services.dart';
import 'frame_engine.dart';

class FrameEngineChannel implements FrameEngine {
  static const MethodChannel _channel = MethodChannel('sela/frame_engine');
  int _instanceId = -1;
  static int _nextId = 0;

  @override
  Future<void> open(String path) async {
    _instanceId = _nextId++;
    await _channel.invokeMethod('open', {
      'id': _instanceId,
      'path': path,
    });
  }

  @override
  Future<List<int>> getFrame(double timeS, {bool exact = false}) async {
    if (_instanceId == -1) throw Exception("Engine not opened");
    final bytes = await _channel.invokeMethod<List<int>>('getFrame', {
      'id': _instanceId,
      'timeMs': (timeS * 1000).toInt(),
      'exact': exact,
    });
    if (bytes == null) throw Exception("Frame extraction returned null");
    // Cast dynamic list to List<int> just to be safe
    return bytes.cast<int>();
  }

  @override
  Future<void> close() async {
    if (_instanceId != -1) {
      await _channel.invokeMethod('close', {'id': _instanceId});
      _instanceId = -1;
    }
  }
}
