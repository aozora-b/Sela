import 'native_video_picker.dart';
import 'video_picker.dart';

/// Backward compatibility adapter for legacy callers of [VideoPickerChannel].
/// Prefer using [VideoPicker] via [videoPickerProvider].
class VideoPickerChannel extends NativeVideoPicker {
  const VideoPickerChannel();
}
