import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'native_video_picker.dart';

/// Abstract interface for selecting video files and storage folders.
abstract class VideoPicker {
  /// Prompts user to pick a video file and returns its path and display name.
  Future<Map<String, dynamic>?> pickVideo();

  /// Prompts user to select a folder and returns video metadata within that folder.
  Future<List<Map<String, dynamic>>?> pickFolder();

  /// Prompts user to select an output storage tree directory.
  Future<Map<String, dynamic>?> pickOutputDirectory();

  /// Copies a video from a SAF content URI into local app storage.
  Future<Map<String, dynamic>?> copyVideoUri(String uri);
}

/// Riverpod provider for injecting [VideoPicker].
final videoPickerProvider = Provider<VideoPicker>((ref) {
  return const NativeVideoPicker();
});
