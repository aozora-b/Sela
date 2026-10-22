import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import 'features/capture/capture_screen.dart';
import 'theme/sela_theme.dart';

void main() {
  runApp(const ProviderScope(child: SelaApp()));
}

class SelaApp extends StatelessWidget {
  const SelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sela',
      debugShowCheckedModeBanner: false,
      theme: SelaTheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id'), Locale('en')],
      home: const CaptureScreen(),
    );
  }
}
