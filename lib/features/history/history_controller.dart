import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/session_models.dart';
import 'history_repository.dart';

class HistoryController extends AsyncNotifier<List<ExtractionSession>> {
  @override
  Future<List<ExtractionSession>> build() {
    return ref.read(historyRepositoryProvider).getHistory();
  }

  Future<void> deleteSession(String id) async {
    final repo = ref.read(historyRepositoryProvider);
    await repo.deleteHistory(id);
    state = AsyncData(await repo.getHistory());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(historyRepositoryProvider).getHistory());
  }
}

final historyProvider =
    AsyncNotifierProvider<HistoryController, List<ExtractionSession>>(
      HistoryController.new,
    );
