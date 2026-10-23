import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../domain/language_models.dart';
import '../../domain/settings_models.dart';
import '../../theme/sela_colors.dart';
import '../../theme/sela_space.dart';
import '../../theme/sela_text.dart';
import 'settings_controller.dart';
import 'widgets/format_selector_card.dart';
import 'widgets/language_picker_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final currentLang = AppLanguage.all.firstWhere(
      (l) => l.code == settings.localeCode,
      orElse: () => AppLanguage.suggested.first,
    );

    return Scaffold(
      backgroundColor: SelaColors.bg,
      appBar: AppBar(
        backgroundColor: SelaColors.bg,
        foregroundColor: SelaColors.textPrimary,
        elevation: 0,
        title: Text(l10n.titleSettings, style: SelaText.titleCard),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: SelaSpace.xl,
          vertical: SelaSpace.md,
        ),
        children: [
          _buildSectionHeader(l10n.sectionExtraction),
          FormatSelectorCard(settings: settings, notifier: notifier),
          const SizedBox(height: SelaSpace.xl),
          _buildSectionHeader(l10n.sectionAppearance),
          _buildThemeSelector(settings, notifier, l10n),
          const SizedBox(height: SelaSpace.xl),
          _buildSectionHeader(l10n.sectionLanguage),
          _buildLanguageTile(context, currentLang),
          const SizedBox(height: SelaSpace.xl),
          _buildSectionHeader(l10n.sectionAbout),
          _buildAboutTile(l10n),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SelaSpace.sm),
      child: Text(
        title,
        style: SelaText.caption.copyWith(color: SelaColors.textSecondary),
      ),
    );
  }

  Widget _buildThemeSelector(
    AppSettings settings,
    SettingsController notifier,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(SelaSpace.sm),
      decoration: const BoxDecoration(
        color: SelaColors.surface,
        borderRadius: SelaRadius.cardBorderRadius,
      ),
      child: SegmentedButton<AppThemeMode>(
        segments: [
          ButtonSegment(
            value: AppThemeMode.dark,
            label: Text(l10n.themeDark),
            icon: const Icon(Icons.dark_mode_outlined),
          ),
          ButtonSegment(
            value: AppThemeMode.light,
            label: Text(l10n.themeLight),
            icon: const Icon(Icons.light_mode_outlined),
          ),
          ButtonSegment(
            value: AppThemeMode.system,
            label: Text(l10n.themeSystem),
            icon: const Icon(Icons.brightness_auto_outlined),
          ),
        ],
        selected: {settings.themeMode},
        onSelectionChanged: (set) => notifier.setThemeMode(set.first),
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, AppLanguage currentLang) {
    return Material(
      color: SelaColors.surface,
      borderRadius: SelaRadius.cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => LanguagePickerSheet.show(context),
        title: Text(currentLang.nativeName, style: SelaText.body),
        subtitle: Text(
          currentLang.englishName,
          style: SelaText.caption.copyWith(color: SelaColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: SelaColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAboutTile(AppLocalizations l10n) {
    return Material(
      color: SelaColors.surface,
      borderRadius: SelaRadius.cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(l10n.appName, style: SelaText.body),
        subtitle: const Text('v1.0.0 (build b6)', style: SelaText.caption),
      ),
    );
  }
}
