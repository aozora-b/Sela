import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sela/l10n/generated/app_localizations.dart';
import 'package:sela/features/capture/capture_screen.dart';
import 'package:sela/features/capture/capture_controller.dart';
import 'package:sela/domain/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('sela/frame_engine'), (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'open') return null;
          if (methodCall.method == 'getFrame') return <int>[1, 2, 3];
          if (methodCall.method == 'close') return null;
          return null;
        });
  });

  testWidgets('Interval chips update frame estimation text for 10s video', (
    WidgetTester tester,
  ) async {
    const info = VideoInfo(
      path: 'test.mp4',
      durationS: 10.0,
      fps: 30,
      width: 1280,
      height: 720,
      frameCount: 300,
      codec: 'h264',
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('id'), Locale('en')],
          locale: Locale('id'),
          home: CaptureScreen(),
        ),
      ),
    );

    final element = tester.element(find.byType(CaptureScreen));
    final container = ProviderScope.containerOf(element);

    // Open video and set mode to Interval (isExactMode = false)
    await container.read(captureProvider.notifier).openVideo('test.mp4', info);
    container.read(captureProvider.notifier).toggleMode(false);
    await tester.pump();

    // Default interval 0.25s -> 40 frames
    expect(find.textContaining('±40 frame'), findsOneWidget);

    // Tap 0.5 dtk chip -> 20 frames
    await tester.tap(find.text('0.5 dtk'));
    await tester.pump();
    expect(find.textContaining('±20 frame'), findsOneWidget);

    // Tap 1 dtk chip -> 10 frames
    await tester.tap(find.text('1 dtk'));
    await tester.pump();
    expect(find.textContaining('±10 frame'), findsOneWidget);

    // Tap 2 dtk chip -> 5 frames
    await tester.tap(find.text('2 dtk'));
    await tester.pump();
    expect(find.textContaining('±5 frame'), findsOneWidget);

    // Tap 5 dtk chip -> 2 frames
    await tester.tap(find.text('5 dtk'));
    await tester.pump();
    expect(find.textContaining('±2 frame'), findsOneWidget);
  });
}
