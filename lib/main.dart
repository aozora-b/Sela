import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import 'features/capture/capture_screen.dart';
import 'features/settings/settings_controller.dart';
import 'theme/sela_theme.dart';

void main() {
  runApp(const ProviderScope(child: SelaApp()));
}

class SelaApp extends ConsumerWidget {
  const SelaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Sela',
      debugShowCheckedModeBanner: false,
      theme: SelaTheme.darkTheme,
      themeMode: settings.themeMode.flutterThemeMode,
      locale: Locale(settings.localeCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CaptureScreen(),
    );
  }
}
