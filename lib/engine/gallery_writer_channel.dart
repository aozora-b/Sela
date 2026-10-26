import 'package:flutter/services.dart';

import 'gallery_writer.dart';

class GalleryWriterChannel implements GalleryWriter {
  static const MethodChannel _channel = MethodChannel(
    'com.echastel.sela/gallery',
  );

  @override
  Future<String> writeImage({
    required List<int> bytes,
    required String displayName,
    required String mimeType,
    String? subfolder,
  }) async {
    final result = await _channel.invokeMethod<String>('writeImage', {
      'bytes': Uint8List.fromList(bytes),
      'displayName': displayName,
      'mimeType': mimeType,
      'subfolder': ?subfolder,
    });
    return result ?? '';
  }

  @override
  Future<bool> exists(String displayName, {String? subfolder}) async {
    final result = await _channel.invokeMethod<bool>('exists', {
      'displayName': displayName,
      'subfolder': ?subfolder,
    });
    return result ?? false;
  }

  @override
  Future<bool> openGallery() async {
    final result = await _channel.invokeMethod<bool>('openGallery');
    return result ?? false;
  }

  @override
  Future<bool> shareImages(List<String> paths) async {
    if (paths.isEmpty) return false;
    final result = await _channel.invokeMethod<bool>('shareImages', {
      'paths': paths,
    });
    return result ?? false;
  }
}
