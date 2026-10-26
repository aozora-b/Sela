import 'package:flutter/services.dart';

import 'video_picker.dart';

/// Native video and directory picker communicating with Android's
/// Storage Access Framework via MethodChannel `sela/video_picker`.
class NativeVideoPicker implements VideoPicker {
  const NativeVideoPicker();

  static const MethodChannel _channel = MethodChannel('sela/video_picker');

  @override
  Future<Map<String, dynamic>?> pickVideo() async {
    return _channel.invokeMapMethod<String, dynamic>('pickVideo');
  }

  @override
  Future<List<Map<String, dynamic>>?> pickFolder() async {
    final res = await _channel.invokeListMethod<dynamic>('pickFolder');
    if (res == null) return null;
    return res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<Map<String, dynamic>?> pickOutputDirectory() async {
    return _channel.invokeMapMethod<String, dynamic>('pickOutputDirectory');
  }

  @override
  Future<Map<String, dynamic>?> copyVideoUri(String uri) async {
    return _channel.invokeMapMethod<String, dynamic>('copyVideoUri', {
      'uri': uri,
    });
  }
}
