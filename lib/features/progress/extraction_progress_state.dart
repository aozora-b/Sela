class ExtractionProgressState {
  final int current;
  final int total;
  final bool isExtracting;
  final bool isCancelled;
  final bool isCompleted;
  final Duration? remainingTime;
  final String? error;
  final String savedAlbum;

  const ExtractionProgressState({
    this.current = 0,
    this.total = 0,
    this.isExtracting = false,
    this.isCancelled = false,
    this.isCompleted = false,
    this.remainingTime,
    this.error,
    this.savedAlbum = 'Pictures/Sela',
  });

  double get progressRatio =>
      total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

  ExtractionProgressState copyWith({
    int? current,
    int? total,
    bool? isExtracting,
    bool? isCancelled,
    bool? isCompleted,
    Duration? remainingTime,
    String? error,
    String? savedAlbum,
  }) {
    return ExtractionProgressState(
      current: current ?? this.current,
      total: total ?? this.total,
      isExtracting: isExtracting ?? this.isExtracting,
      isCancelled: isCancelled ?? this.isCancelled,
      isCompleted: isCompleted ?? this.isCompleted,
      remainingTime: remainingTime ?? this.remainingTime,
      error: error ?? this.error,
      savedAlbum: savedAlbum ?? this.savedAlbum,
    );
  }
}
