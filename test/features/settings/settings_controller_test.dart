import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/settings_models.dart';
import 'package:sela/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'SettingsController modifies format, quality, theme, and locale',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(settingsProvider.notifier);
      await notifier.setFormat(OutputFormat.jpeg);
      expect(container.read(settingsProvider).format, OutputFormat.jpeg);

      await notifier.setJpegQuality(75);
      expect(container.read(settingsProvider).jpegQuality, 75);

      await notifier.setThemeMode(AppThemeMode.system);
      expect(container.read(settingsProvider).themeMode, AppThemeMode.system);

      await notifier.setLocale('en');
      expect(container.read(settingsProvider).localeCode, 'en');
    },
  );
}
