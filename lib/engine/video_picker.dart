import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'native_video_picker.dart';

/// Antarmuka abstrak untuk memilih berkas video dan folder dari sistem berkas/SAF.
abstract class VideoPicker {
  /// Membuka pemilih berkas dan mengembalikan map dengan kunci `path`
  /// dan `displayName`, atau `null` jika pengguna membatalkan.
  Future<Map<String, dynamic>?> pickVideo();

  /// Membuka pemilih folder dan mengembalikan daftar metadata video di dalam folder.
  Future<List<Map<String, dynamic>>?> pickFolder();

  /// Membuka pemilih folder tujuan penyimpanan (`treeUri` dan `displayPath`).
  Future<Map<String, dynamic>?> pickOutputDirectory();

  /// Menyalin video dari URI SAF ke penyimpanan cache lokal dan mengembalikan map `path` dan `displayName`.
  Future<Map<String, dynamic>?> copyVideoUri(String uri);
}

/// Provider Riverpod untuk injeksi dependensi pemilih video.
final videoPickerProvider = Provider<VideoPicker>((ref) {
  return const NativeVideoPicker();
});
