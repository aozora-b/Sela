import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/models.dart';
import 'package:sela/features/results/results_controller.dart';
import 'package:sela/features/results/results_screen.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

void main() {
  const dummyFrames = [
    FrameResult(
      path: '/data/cache/frame_1.jpg',
      timestampS: 0.5,
      index: 1,
      sizeBytes: 1024 * 1024,
    ),
    FrameResult(
      path: '/data/cache/frame_2.jpg',
      timestampS: 1.0,
      index: 2,
      sizeBytes: 1024 * 1024,
    ),
  ];

  Widget buildApp(List<FrameResult> frames) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        home: ResultsScreen(initialFrames: frames),
      ),
    );
  }

  testWidgets('ResultsScreen displays title, selection count, and frames', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp(dummyFrames));
    final element = tester.element(find.byType(ResultsScreen));
    final container = ProviderScope.containerOf(element);
    container.read(resultsProvider.notifier).setFrames(dummyFrames);
    await tester.pumpAndSettle();

    expect(find.text('Foto (2)'), findsOneWidget);
    expect(find.text('Ketuk untuk memilih foto'), findsOneWidget);
    expect(find.text('Simpan Semua'), findsOneWidget);
    expect(find.text('Simpan yang Dipilih'), findsOneWidget);

    // Toggle select by tapping frame
    final controller = container.read(resultsProvider.notifier);
    controller.deselectAll();
    await tester.pumpAndSettle();
    expect(container.read(resultsProvider).selectedCount, 0);

    controller.selectAll();
    await tester.pumpAndSettle();
    expect(container.read(resultsProvider).selectedCount, 2);

    await tester.tap(find.text('Simpan Semua'));
    await tester.pump();
    expect(find.textContaining('tersimpan di'), findsOneWidget);
  });
}
