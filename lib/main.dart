import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import 'features/home/home_screen.dart';
import 'features/settings/settings_controller.dart';
import 'theme/sela_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 40;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 40 * 1024 * 1024;
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
      theme: SelaTheme.lightTheme,
      darkTheme: SelaTheme.darkTheme,
      themeMode: settings.themeMode.flutterThemeMode,
      locale: Locale(settings.localeCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
