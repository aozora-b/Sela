import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/settings_models.dart';

class SettingsRepository {
  static const _keyFormat = 'settings_format';
  static const _keyQuality = 'settings_jpeg_quality';
  static const _keyTheme = 'settings_theme_mode';
  static const _keyLocale = 'settings_locale';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<AppSettings> loadSettings() async {
    final prefs = await _prefs;
    final formatStr = prefs.getString(_keyFormat) ?? 'png';
    final quality = prefs.getInt(_keyQuality) ?? 90;
    final themeStr = prefs.getString(_keyTheme) ?? 'dark';
    final locale = prefs.getString(_keyLocale) ?? 'id';

    final format = formatStr == 'jpeg' ? OutputFormat.jpeg : OutputFormat.png;
    final theme = AppThemeMode.values.firstWhere(
      (t) => t.name == themeStr,
      orElse: () => AppThemeMode.dark,
    );

    return AppSettings(
      format: format,
      jpegQuality: quality.clamp(1, 100),
      themeMode: theme,
      localeCode: locale,
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await _prefs;
    await prefs.setString(_keyFormat, settings.format.name);
    await prefs.setInt(_keyQuality, settings.jpegQuality);
    await prefs.setString(_keyTheme, settings.themeMode.name);
    await prefs.setString(_keyLocale, settings.localeCode);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);
