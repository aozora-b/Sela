import 'package:flutter/services.dart';

/// Saluran komunikasi ke pemilih video native (Storage Access Framework).
///
/// Membuka pemilih `ACTION_OPEN_DOCUMENT` bertipe `video/*`, lalu menyalin
/// berkas terpilih ke direktori cache aplikasi. Engine hanya menerima path
/// nyata, bukan URI `content://`, sehingga berkas harus disalin terlebih
/// dahulu.
class VideoPickerChannel {
  static const MethodChannel _channel = MethodChannel('sela/video_picker');

  /// Menampilkan pemilih video dan mengembalikan hasil pilihan.
  ///
  /// Mengembalikan `null` bila pengguna membatalkan pemilihan. Bila berhasil,
  /// mengembalikan [Map] berisi `path` (lokasi berkas hasil salinan) dan
  /// `displayName` (nama berkas asli). Melempar [PlatformException] bila
  /// terjadi kesalahan di sisi native.
  Future<Map<String, dynamic>?> pickVideo() async {
    return _channel.invokeMapMethod<String, dynamic>('pickVideo');
  }
}
