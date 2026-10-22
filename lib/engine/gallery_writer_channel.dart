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
  }) async {
    final result = await _channel.invokeMethod<String>('writeImage', {
      'bytes': Uint8List.fromList(bytes),
      'displayName': displayName,
      'mimeType': mimeType,
    });
    return result ?? '';
  }

  @override
  Future<bool> exists(String displayName) async {
    final result = await _channel.invokeMethod<bool>('exists', {
      'displayName': displayName,
    });
    return result ?? false;
  }

  @override
  Future<bool> openGallery() async {
    final result = await _channel.invokeMethod<bool>('openGallery');
    return result ?? false;
  }
}
