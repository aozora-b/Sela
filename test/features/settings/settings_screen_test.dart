import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/features/settings/settings_screen.dart';
import 'package:sela/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
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
      home: SettingsScreen(),
    ),
  );

  testWidgets('SettingsScreen displays all sections and options', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Setelan'), findsOneWidget);
    expect(find.text('Ekstraksi'), findsOneWidget);
    expect(find.text('Tampilan'), findsOneWidget);
    expect(find.text('Bahasa'), findsOneWidget);
    expect(find.text('Tentang'), findsOneWidget);
    expect(find.text('Bahasa Indonesia'), findsOneWidget);

    // Switch to JPEG
    await tester.tap(find.text('JPEG'));
    await tester.pumpAndSettle();

    expect(find.text('Kualitas JPEG'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
  });

  testWidgets('SettingsScreen opens LanguagePickerSheet when tapped', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bahasa Indonesia'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Bahasa'), findsOneWidget);
    expect(find.text('Disarankan'), findsOneWidget);
    expect(find.text('Semua Bahasa'), findsOneWidget);
  });
}
