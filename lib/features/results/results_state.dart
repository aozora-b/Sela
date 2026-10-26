import '../../domain/models.dart';

/// Immutable state representing results screen frames, selections, and export status.
class ResultsState {
  const ResultsState({
    this.frames = const [],
    this.selectedIndices = const {},
    this.videoStem = '',
    this.isSaving = false,
  });

  final List<FrameResult> frames;
  final Set<int> selectedIndices;
  final String videoStem;
  final bool isSaving;

  int get selectedCount => selectedIndices.length;
  int get totalCount => frames.length;

  int get totalSizeBytes => frames.fold(0, (sum, f) => sum + f.sizeBytes);

  int get selectedSizeBytes {
    return frames
        .where((f) => selectedIndices.contains(f.index))
        .fold(0, (sum, f) => sum + f.sizeBytes);
  }

  ResultsState copyWith({
    List<FrameResult>? frames,
    Set<int>? selectedIndices,
    String? videoStem,
    bool? isSaving,
  }) {
    return ResultsState(
      frames: frames ?? this.frames,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      videoStem: videoStem ?? this.videoStem,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
