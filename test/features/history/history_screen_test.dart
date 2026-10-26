import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/session_models.dart';
import 'package:sela/features/history/history_controller.dart';
import 'package:sela/features/history/history_screen.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

class MockHistoryController extends HistoryController {
  final List<ExtractionSession> initial;
  MockHistoryController(this.initial);

  @override
  Future<List<ExtractionSession>> build() async => List.from(initial);

  @override
  Future<void> deleteSession(String id) async {
    final list = List<ExtractionSession>.from(state.value ?? []);
    list.removeWhere((s) => s.id == id);
    state = AsyncData(list);
  }
}

void main() {
  Widget buildTestWidget({List<ExtractionSession> sessions = const []}) {
    return ProviderScope(
      overrides: [
        historyProvider.overrideWith(() => MockHistoryController(sessions)),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('id')],
        locale: Locale('id'),
        home: HistoryScreen(),
      ),
    );
  }

  testWidgets('displays empty state when no history exists', (tester) async {
    await tester.pumpWidget(buildTestWidget(sessions: []));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada riwayat ekstraksi'), findsOneWidget);
  });

  testWidgets('displays session item details and allows deletion', (
    tester,
  ) async {
    final sessions = [
      ExtractionSession(
        id: 'sess_1',
        videoPath: 'my_holiday.mp4',
        savedCount: 15,
        lastIndex: 15,
        total: 15,
        timestamp: DateTime(2026, 10, 23, 14, 30),
        totalSizeBytes: 2 * 1024 * 1024,
      ),
    ];

    await tester.pumpWidget(buildTestWidget(sessions: sessions));
    await tester.pumpAndSettle();

    expect(find.text('my_holiday.mp4'), findsOneWidget);
    expect(find.textContaining('15 frame'), findsOneWidget);

    // Test swipe to dismiss
    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat dihapus'), findsOneWidget);
    expect(find.text('my_holiday.mp4'), findsNothing);
  });
}
