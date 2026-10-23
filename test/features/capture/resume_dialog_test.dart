import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/session_models.dart';
import 'package:sela/features/capture/widgets/resume_dialog.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

void main() {
  Widget buildApp(Widget child) => MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('id')],
    locale: const Locale('id'),
    home: Scaffold(body: child),
  );

  testWidgets('ResumeDialog renders text and returns true on Lanjutkan', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: ctx,
                builder: (_) => const ResumeDialog(nextFrame: 6),
              );
            },
            child: const Text('Show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.text('Lanjutkan Ekstraksi?'), findsOneWidget);
    expect(find.text('Lanjutkan dari frame 6?'), findsOneWidget);
    expect(find.text('Mulai Ulang'), findsOneWidget);
    expect(find.text('Lanjutkan'), findsOneWidget);

    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('ResumeDialog returns false on Mulai Ulang', (tester) async {
    bool? result;
    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: ctx,
                builder: (_) => const ResumeDialog(nextFrame: 12),
              );
            },
            child: const Text('Show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mulai Ulang'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  group('Resume gate validation (0 < savedCount < total)', () {
    bool shouldTriggerResume(ExtractionSession session) {
      return session.savedCount > 0 && session.savedCount < session.total;
    }

    test('triggers resume when partially completed', () {
      final s = ExtractionSession(
        id: 'test',
        videoPath: 'test.mp4',
        savedCount: 5,
        lastIndex: 5,
        total: 40,
        timestamp: DateTime.now(),
        totalSizeBytes: 1024,
      );
      expect(shouldTriggerResume(s), isTrue);
    });

    test('does not trigger resume when savedCount is 0', () {
      final s = ExtractionSession(
        id: 'test',
        videoPath: 'test.mp4',
        savedCount: 0,
        lastIndex: 0,
        total: 40,
        timestamp: DateTime.now(),
        totalSizeBytes: 0,
      );
      expect(shouldTriggerResume(s), isFalse);
    });

    test('does not trigger resume when session is already completed', () {
      final s = ExtractionSession(
        id: 'test',
        videoPath: 'test.mp4',
        savedCount: 40,
        lastIndex: 40,
        total: 40,
        timestamp: DateTime.now(),
        totalSizeBytes: 2048,
      );
      expect(shouldTriggerResume(s), isFalse);
    });
  });
}
