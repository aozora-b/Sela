abstract class GalleryWriter {
  /// Writes image [bytes] to the gallery with [displayName] and [mimeType].
  /// Returns the storage URI or path of the written image.
  Future<String> writeImage({
    required List<int> bytes,
    required String displayName,
    required String mimeType,
  });

  /// Checks if an image with [displayName] already exists in the Sela album.
  Future<bool> exists(String displayName);

  /// Opens the system gallery or photo viewer.
  Future<bool> openGallery();
}
