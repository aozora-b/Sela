import '../domain/models.dart';

abstract class FrameEngine {
  Future<VideoInfo> open(String path);
  Future<List<int>> getFrame(
    double timeS, {
    bool exact = false,
    int? width,
    int? height,
    String format = 'jpeg',
    int quality = 90,
  });
  Future<void> close();
}
