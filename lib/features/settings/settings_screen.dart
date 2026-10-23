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
    final colors = context.colors;

    final currentLang = AppLanguage.all.firstWhere(
      (l) => l.code == settings.localeCode,
      orElse: () => AppLanguage.suggested.first,
    );

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          l10n.titleSettings,
          style: SelaText.of(context, SelaText.titleCard),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: SelaSpace.xl,
          vertical: SelaSpace.md,
        ),
        children: [
          _buildSectionHeader(context, l10n.sectionExtraction, colors),
          FormatSelectorCard(settings: settings, notifier: notifier),
          const SizedBox(height: SelaSpace.xl),
          _buildSectionHeader(context, l10n.sectionAppearance, colors),
          _buildThemeSelector(settings, notifier, l10n, colors),
          const SizedBox(height: SelaSpace.xl),
          _buildSectionHeader(context, l10n.sectionLanguage, colors),
          _buildLanguageTile(context, currentLang, colors),
          const SizedBox(height: SelaSpace.xl),
          _buildSectionHeader(context, l10n.sectionAbout, colors),
          _buildAboutTile(l10n, colors),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    SelaColorsData colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SelaSpace.sm),
      child: Text(
        title,
        style: SelaText.of(context, SelaText.caption, isSecondary: true),
      ),
    );
  }

  Widget _buildThemeSelector(
    AppSettings settings,
    SettingsController notifier,
    AppLocalizations l10n,
    SelaColorsData colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(SelaSpace.sm),
      decoration: BoxDecoration(
        color: colors.surface,
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

  Widget _buildLanguageTile(
    BuildContext context,
    AppLanguage currentLang,
    SelaColorsData colors,
  ) {
    return Material(
      color: colors.surface,
      borderRadius: SelaRadius.cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () => LanguagePickerSheet.show(context),
        title: Text(
          currentLang.nativeName,
          style: SelaText.body.copyWith(color: colors.textPrimary),
        ),
        subtitle: Text(
          currentLang.englishName,
          style: SelaText.caption.copyWith(color: colors.textSecondary),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildAboutTile(AppLocalizations l10n, SelaColorsData colors) {
    return Material(
      color: colors.surface,
      borderRadius: SelaRadius.cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          l10n.appName,
          style: SelaText.body.copyWith(color: colors.textPrimary),
        ),
        subtitle: Text(
          'v1.0.0 (build b6)',
          style: SelaText.caption.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}
