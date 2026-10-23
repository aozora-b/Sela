import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sela/domain/session_models.dart';
import 'package:sela/features/history/history_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HistoryRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = HistoryRepository();
  });

  test('active session can be saved and retrieved', () async {
    final session = ExtractionSession(
      id: 'active_1',
      videoPath: 'test.mp4',
      savedCount: 5,
      lastIndex: 5,
      total: 10,
      timestamp: DateTime(2026, 10, 23, 8, 0),
      totalSizeBytes: 50000,
    );

    await repo.saveActiveSession(session);
    final fetched = await repo.getActiveSession('test.mp4');

    expect(fetched, isNotNull);
    expect(fetched!.savedCount, 5);
    expect(fetched.total, 10);
    expect(fetched.videoPath, 'test.mp4');
  });

  test('clearActiveSession removes active session', () async {
    await repo.recordProgress(
      videoPath: 'sample.mp4',
      savedCount: 3,
      total: 8,
      totalBytes: 30000,
    );

    expect(await repo.getActiveSession('sample.mp4'), isNotNull);
    await repo.clearActiveSession('sample.mp4');
    expect(await repo.getActiveSession('sample.mp4'), isNull);
  });

  test('recordCompleted adds to history and clears active session', () async {
    await repo.recordProgress(
      videoPath: 'vid.mp4',
      savedCount: 2,
      total: 4,
      totalBytes: 20000,
    );

    await repo.recordCompleted(
      videoPath: 'vid.mp4',
      total: 4,
      totalBytes: 40000,
    );

    expect(await repo.getActiveSession('vid.mp4'), isNull);

    final history = await repo.getHistory();
    expect(history.length, 1);
    expect(history.first.savedCount, 4);
    expect(history.first.totalSizeBytes, 40000);
  });

  test('deleteHistory removes item from history', () async {
    final s1 = ExtractionSession(
      id: 's1',
      videoPath: 'v1.mp4',
      savedCount: 10,
      lastIndex: 10,
      total: 10,
      timestamp: DateTime.now(),
    );
    final s2 = ExtractionSession(
      id: 's2',
      videoPath: 'v2.mp4',
      savedCount: 20,
      lastIndex: 20,
      total: 20,
      timestamp: DateTime.now(),
    );

    await repo.addHistory(s1);
    await repo.addHistory(s2);

    var history = await repo.getHistory();
    expect(history.length, 2);

    await repo.deleteHistory('s1');
    history = await repo.getHistory();
    expect(history.length, 1);
    expect(history.first.id, 's2');
  });
}
