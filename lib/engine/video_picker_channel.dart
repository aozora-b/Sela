import 'native_video_picker.dart';
import 'video_picker.dart';

/// Kompatibilitas mundur untuk pemanggil lama yang menggunakan [VideoPickerChannel].
/// Direkomendasikan menggunakan [VideoPicker] via [videoPickerProvider].
class VideoPickerChannel extends NativeVideoPicker {
  const VideoPickerChannel();
}
