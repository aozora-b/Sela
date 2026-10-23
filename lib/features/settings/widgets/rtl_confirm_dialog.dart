import 'package:flutter/material.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../domain/language_models.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';

class RtlConfirmDialog extends StatelessWidget {
  final AppLanguage targetLanguage;

  const RtlConfirmDialog({super.key, required this.targetLanguage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: SelaColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: SelaRadius.cardBorderRadius,
      ),
      title: Text(l10n.dialogRtlTitle, style: SelaText.titleCard),
      content: Text(
        l10n.dialogRtlMessage(targetLanguage.nativeName),
        style: SelaText.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l10n.btnCancel,
            style: SelaText.button.copyWith(color: SelaColors.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: SelaColors.accent,
            foregroundColor: SelaColors.textPrimary,
            shape: const RoundedRectangleBorder(
              borderRadius: SelaRadius.pillBorderRadius,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.btnApply, style: SelaText.button),
        ),
      ],
    );
  }
}
