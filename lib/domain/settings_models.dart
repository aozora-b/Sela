import 'formats.dart';

export 'formats.dart' show OutputFormat, OutputFormatX;

enum AppThemeMode { dark, light, system }

class AppSettings {
  final OutputFormat format;
  final int jpegQuality;
  final AppThemeMode themeMode;
  final String localeCode;

  const AppSettings({
    this.format = OutputFormat.png,
    this.jpegQuality = 90,
    this.themeMode = AppThemeMode.dark,
    this.localeCode = 'id',
  });

  AppSettings copyWith({
    OutputFormat? format,
    int? jpegQuality,
    AppThemeMode? themeMode,
    String? localeCode,
  }) {
    return AppSettings(
      format: format ?? this.format,
      jpegQuality: jpegQuality ?? this.jpegQuality,
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
    );
  }
}
