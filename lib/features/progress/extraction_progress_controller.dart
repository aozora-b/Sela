import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'extraction_progress_state.dart';

class ExtractionProgressNotifier extends Notifier<ExtractionProgressState> {
  @override
  ExtractionProgressState build() => const ExtractionProgressState();

  void start(int total) {
    state = ExtractionProgressState(
      total: total,
      current: 0,
      isExtracting: true,
      isCancelled: false,
      isCompleted: false,
    );
  }

  void updateProgress({required int current, required Duration remaining}) {
    state = state.copyWith(
      current: current,
      remainingTime: remaining,
      isExtracting: true,
    );
  }

  void cancel(int current) {
    state = state.copyWith(
      current: current,
      isExtracting: false,
      isCancelled: true,
    );
  }

  void complete(int total) {
    state = state.copyWith(
      current: total,
      isExtracting: false,
      isCompleted: true,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      error: message,
      isExtracting: false,
      isCompleted: false,
    );
  }
}

final extractionProgressProvider =
    NotifierProvider<ExtractionProgressNotifier, ExtractionProgressState>(
      ExtractionProgressNotifier.new,
    );
