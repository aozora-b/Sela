import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../domain/language_models.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import '../settings_controller.dart';
import 'language_tile.dart';
import 'rtl_confirm_dialog.dart';

class LanguagePickerSheet extends ConsumerStatefulWidget {
  const LanguagePickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    final colors = context.colors;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const LanguagePickerSheet(),
    );
  }

  @override
  ConsumerState<LanguagePickerSheet> createState() =>
      _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends ConsumerState<LanguagePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage(AppLanguage lang, String currentLocale) async {
    final messenger = ScaffoldMessenger.of(context);
    final accentColor = context.colors.accent;
    final currentIsRtl = AppLanguage.isLanguageRtl(currentLocale);
    final involvesRtl = lang.isRtl || currentIsRtl;

    if (involvesRtl && lang.code != currentLocale) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => RtlConfirmDialog(targetLanguage: lang),
      );
      if (confirm != true || !mounted) return;
    }

    if (!mounted) return;
    final prev = currentLocale;
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.setLocale(lang.code);
    if (!mounted) return;

    Navigator.of(context).pop();

    if (!involvesRtl && prev != lang.code) {
      final newL10n = await AppLocalizations.delegate.load(Locale(lang.code));
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(newL10n.languageChanged),
          action: SnackBarAction(
            label: newL10n.btnUndo,
            textColor: accentColor,
            onPressed: () => notifier.setLocale(prev),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(settingsProvider).localeCode;
    final colors = context.colors;

    final filteredAll = AppLanguage.all.where((l) {
      final q = _query.toLowerCase();
      return l.nativeName.toLowerCase().contains(q) ||
          l.englishName.toLowerCase().contains(q);
    }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scroll) => Column(
        children: [
          const SizedBox(height: SelaSpace.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.surfaceHighlight,
              borderRadius: SelaRadius.pillBorderRadius,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SelaSpace.md),
            child: Text(
              l10n.titleSelectLanguage,
              style: SelaText.titleCard.copyWith(color: colors.textPrimary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SelaSpace.xl),
            child: TextField(
              controller: _searchController,
              style: SelaText.body.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.searchLanguage,
                hintStyle: SelaText.body.copyWith(color: colors.textSecondary),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.textSecondary,
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colors.surfaceHighlight,
                border: const OutlineInputBorder(
                  borderRadius: SelaRadius.cardBorderRadius,
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
          ),
          const SizedBox(height: SelaSpace.sm),
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.symmetric(horizontal: SelaSpace.xl),
              children: [
                if (_query.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: SelaSpace.sm),
                    child: Text(
                      l10n.sectionSuggested,
                      style: SelaText.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  ...AppLanguage.suggested.map(
                    (l) => LanguageTile(
                      lang: l,
                      isSelected: l.code == currentLocale,
                      onTap: () => _selectLanguage(l, currentLocale),
                    ),
                  ),
                  Divider(color: colors.surfaceHighlight),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: SelaSpace.sm),
                  child: Text(
                    l10n.sectionAllLanguages,
                    style: SelaText.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                ...filteredAll.map(
                  (l) => LanguageTile(
                    lang: l,
                    isSelected: l.code == currentLocale,
                    onTap: () => _selectLanguage(l, currentLocale),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
