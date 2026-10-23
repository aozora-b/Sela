import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/models.dart';
import 'package:sela/features/capture/capture_controller.dart';
import 'package:sela/features/capture/capture_screen.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const info = VideoInfo(
    path: 'test.mp4',
    durationS: 10.0,
    fps: 30,
    width: 1280,
    height: 720,
    frameCount: 300,
    codec: 'h264',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('sela/frame_engine'), (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'open') return null;
          if (methodCall.method == 'getFrame') {
            return base64Decode(
              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
            );
          }
          if (methodCall.method == 'close') return null;
          return null;
        });
  });

  Widget buildApp() => const ProviderScope(
    child: MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('id')],
      locale: Locale('id'),
      home: CaptureScreen(),
    ),
  );

  testWidgets('Interval chips update frame estimation text for 10s video', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildApp());
    final element = tester.element(find.byType(CaptureScreen));
    final container = ProviderScope.containerOf(element);

    await container.read(captureProvider.notifier).openVideo('test.mp4', info);
    container.read(captureProvider.notifier).toggleMode(false);
    await tester.pump();

    expect(find.textContaining('±40 frame'), findsOneWidget);
    await tester.tap(find.text('0.5 dtk'));
    await tester.pump();
    expect(find.textContaining('±20 frame'), findsOneWidget);
    await tester.tap(find.text('1 dtk'));
    await tester.pump();
    expect(find.textContaining('±10 frame'), findsOneWidget);
    await tester.tap(find.text('2 dtk'));
    await tester.pump();
    expect(find.textContaining('±5 frame'), findsOneWidget);
    await tester.tap(find.text('5 dtk'));
    await tester.pump();
    expect(find.textContaining('±2 frame'), findsOneWidget);
  });

  testWidgets('Simpan Frame Ini shows success SnackBar when gallery succeeds', (
    WidgetTester tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.echastel.sela/gallery'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'writeImage') return 'content://media/1';
            if (methodCall.method == 'exists') return false;
            return null;
          },
        );

    await tester.pumpWidget(buildApp());
    final element = tester.element(find.byType(CaptureScreen));
    final container = ProviderScope.containerOf(element);
    await container.read(captureProvider.notifier).openVideo('test.mp4', info);
    await tester.pump();

    await tester.ensureVisible(find.text('Simpan Frame Ini'));
    await tester.tap(find.text('Simpan Frame Ini'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Frame tersimpan di Pictures/Sela'), findsOneWidget);
  });

  testWidgets('Simpan Frame Ini shows failure SnackBar when gallery throws', (
    WidgetTester tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.echastel.sela/gallery'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'writeImage') {
              throw PlatformException(code: 'ERROR');
            }
            return null;
          },
        );

    await tester.pumpWidget(buildApp());
    final element = tester.element(find.byType(CaptureScreen));
    final container = ProviderScope.containerOf(element);
    await container.read(captureProvider.notifier).openVideo('test.mp4', info);
    await tester.pump();

    await tester.ensureVisible(find.text('Simpan Frame Ini'));
    await tester.tap(find.text('Simpan Frame Ini'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Gagal menyimpan frame'), findsOneWidget);
  });
}
