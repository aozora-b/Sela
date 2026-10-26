abstract class GalleryWriter {
  /// Writes image [bytes] to the gallery with [displayName] and [mimeType].
  /// Optionally accepts [subfolder] (e.g. 'Sela/video_title').
  /// Returns the storage URI or path of the written image.
  Future<String> writeImage({
    required List<int> bytes,
    required String displayName,
    required String mimeType,
    String? subfolder,
  });

  /// Checks if an image with [displayName] already exists in the Sela album.
  Future<bool> exists(String displayName, {String? subfolder});

  /// Opens the system gallery or photo viewer.
  Future<bool> openGallery();

  /// Shares images using the native system share sheet.
  Future<bool> shareImages(List<String> paths);
}
