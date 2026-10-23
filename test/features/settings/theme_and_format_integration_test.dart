import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/models.dart';
import 'package:sela/features/settings/settings_screen.dart';
import 'package:sela/l10n/generated/app_localizations.dart';
import 'package:sela/theme/sela_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SelaTheme Production Verification', () {
    test('lightTheme has Brightness.light and Editorial Light palette', () {
      final theme = SelaTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, SelaColors.bgLight);
      expect(theme.colorScheme.primary, SelaColors.accent);
      expect(theme.colorScheme.surface, SelaColors.surfaceLight);
      expect(theme.colorScheme.onSurface, SelaColors.textPrimaryLight);
    });

    test('darkTheme has Brightness.dark and Editorial Dark palette', () {
      final theme = SelaTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, SelaColors.bg);
      expect(theme.colorScheme.primary, SelaColors.accent);
      expect(theme.colorScheme.surface, SelaColors.surface);
      expect(theme.colorScheme.onSurface, SelaColors.textPrimary);
    });

    testWidgets(
      'SettingsScreen renders with SelaColors.bgLight in lightTheme',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: SelaTheme.lightTheme,
              themeMode: ThemeMode.light,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('id'),
              home: const SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, SelaColors.bgLight);
      },
    );

    testWidgets('SettingsScreen renders with SelaColors.bg in darkTheme', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: SelaTheme.darkTheme,
            themeMode: ThemeMode.dark,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('id'),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, SelaColors.bg);
    });

    test(
      'SelaText styles do not hardcode textPrimary/textSecondary colors',
      () {
        expect(SelaText.displaySerif.color, isNull);
        expect(SelaText.progressNumber.color, isNull);
        expect(SelaText.titleCard.color, isNull);
        expect(SelaText.body.color, isNull);
        expect(SelaText.button.color, isNull);
        expect(SelaText.sectionLabel.color, isNull);
        expect(SelaText.caption.color, isNull);
      },
    );

    testWidgets(
      'SelaText.of dynamically injects theme-appropriate text colors',
      (tester) async {
        late BuildContext lightCtx, darkCtx;
        await tester.pumpWidget(
          MaterialApp(
            theme: SelaTheme.lightTheme,
            themeMode: ThemeMode.light,
            home: Builder(
              builder: (ctx) {
                lightCtx = ctx;
                return const SizedBox();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          SelaText.of(lightCtx, SelaText.titleCard).color,
          SelaColors.textPrimaryLight,
        );
        expect(
          SelaText.of(lightCtx, SelaText.caption, isSecondary: true).color,
          SelaColors.textSecondaryLight,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: SelaTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: Builder(
              builder: (ctx) {
                darkCtx = ctx;
                return const SizedBox();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          SelaText.of(darkCtx, SelaText.titleCard).color,
          SelaColors.textPrimary,
        );
        expect(
          SelaText.of(darkCtx, SelaText.caption, isSecondary: true).color,
          SelaColors.textSecondary,
        );
      },
    );

    test('TextTheme colors correctly mirror active theme brightness', () {
      final lightText = SelaTheme.lightTheme.textTheme;
      expect(lightText.displayLarge?.color, SelaColors.textPrimaryLight);
      expect(lightText.bodyMedium?.color, SelaColors.textSecondaryLight);

      final darkText = SelaTheme.darkTheme.textTheme;
      expect(darkText.displayLarge?.color, SelaColors.textPrimary);
      expect(darkText.bodyMedium?.color, SelaColors.textSecondary);
    });
  });

  group('OutputFormat Unified Production Enum & Extensions', () {
    test('PNG mapping produces png extension and image/png mimeType', () {
      const fmt = OutputFormat.png;
      expect(fmt.ext, 'png');
      expect(fmt.mimeType, 'image/png');
      expect(fmt.label, 'PNG');
    });

    test('JPEG mapping produces jpg extension and image/jpeg mimeType', () {
      const fmt = OutputFormat.jpeg;
      expect(fmt.ext, 'jpg');
      expect(fmt.mimeType, 'image/jpeg');
      expect(fmt.label, 'JPEG');
    });

    test('ExtractOptions accepts OutputFormat.jpeg and custom quality', () {
      final opt = ExtractOptions(
        mode: CaptureMode.interval,
        intervalS: 2.0,
        fmt: OutputFormat.jpeg,
        quality: 85,
      );
      expect(opt.fmt, OutputFormat.jpeg);
      expect(opt.quality, 85);
      expect(opt.fmt.ext, 'jpg');
      expect(opt.fmt.mimeType, 'image/jpeg');
    });
  });
}
