abstract class FrameEngine {
  Future<void> open(String path);
  Future<List<int>> getFrame(double timeS, {bool exact = false});
  Future<void> close();
}
