import '../domain/models.dart';

abstract class FrameEngine {
  Future<VideoInfo> open(String path);
  Future<List<int>> getFrame(
    double timeS, {
    bool exact = false,
    int? width,
    int? height,
  });
  Future<void> close();
}
