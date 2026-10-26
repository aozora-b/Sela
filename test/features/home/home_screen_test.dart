import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/engine/video_picker.dart';
import 'package:sela/features/home/home_screen.dart';
import 'package:sela/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockVideoPicker implements VideoPicker {
  bool picked = false;

  @override
  Future<Map<String, dynamic>?> pickVideo() async {
    picked = true;
    return {'path': 'sample.mp4', 'displayName': 'sample.mp4'};
  }

  @override
  Future<List<Map<String, dynamic>>?> pickFolder() async => [];

  @override
  Future<Map<String, dynamic>?> pickOutputDirectory() async => null;

  @override
  Future<Map<String, dynamic>?> copyVideoUri(String uri) async => null;
}

void main() {
  testWidgets('HomeScreen renders tabs and switches between them', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final mockPicker = MockVideoPicker();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [videoPickerProvider.overrideWithValue(mockPicker)],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('id')],
          locale: Locale('id'),
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check header and wordmark
    expect(find.textContaining('Ambil momen'), findsOneWidget);
    expect(find.text('Pilih video'), findsOneWidget);
    expect(find.text('Pilih folder'), findsOneWidget);

    // Switch to Riwayat tab
    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada riwayat ekstraksi'), findsOneWidget);

    // Switch to Setelan tab
    await tester.tap(find.text('Setelan'));
    await tester.pumpAndSettle();
    expect(find.text('Format Berkas'), findsOneWidget);

    // Switch back to Ekstrak tab
    await tester.tap(find.text('Ekstrak'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih video'), findsOneWidget);

    // Tap pick folder calls picker and shows notice if empty
    await tester.tap(find.text('Pilih folder'));
    await tester.pump();
    expect(find.textContaining('Tidak ada berkas video'), findsOneWidget);
  });
}
