import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/settings_models.dart';
import 'settings_repository.dart';

class SettingsController extends Notifier<AppSettings> {
  late final _repo = ref.read(settingsRepositoryProvider);

  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    final loaded = await _repo.loadSettings();
    state = loaded;
  }

  Future<void> setFormat(OutputFormat format) async {
    state = state.copyWith(format: format);
    await _repo.saveSettings(state);
  }

  Future<void> setJpegQuality(int quality) async {
    state = state.copyWith(jpegQuality: quality.clamp(1, 100));
    await _repo.saveSettings(state);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.saveSettings(state);
  }

  Future<void> setLocale(String code) async {
    state = state.copyWith(localeCode: code);
    await _repo.saveSettings(state);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

extension AppThemeModeX on AppThemeMode {
  ThemeMode get flutterThemeMode {
    switch (this) {
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
