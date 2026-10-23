import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/settings_models.dart';
import 'package:sela/features/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadSettings returns default values when empty', () async {
    final repo = SettingsRepository();
    final settings = await repo.loadSettings();

    expect(settings.format, OutputFormat.png);
    expect(settings.jpegQuality, 90);
    expect(settings.themeMode, AppThemeMode.dark);
    expect(settings.localeCode, 'id');
  });

  test('saveSettings persists and restores values correctly', () async {
    final repo = SettingsRepository();
    const custom = AppSettings(
      format: OutputFormat.jpeg,
      jpegQuality: 85,
      themeMode: AppThemeMode.light,
      localeCode: 'en',
    );

    await repo.saveSettings(custom);
    final loaded = await repo.loadSettings();

    expect(loaded.format, OutputFormat.jpeg);
    expect(loaded.jpegQuality, 85);
    expect(loaded.themeMode, AppThemeMode.light);
    expect(loaded.localeCode, 'en');
  });
}
