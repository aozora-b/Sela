import 'package:flutter/material.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';

class ResumeDialog extends StatelessWidget {
  final int nextFrame;
  const ResumeDialog({super.key, required this.nextFrame});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: SelaRadius.cardBorderRadius,
      ),
      title: Text(
        l10n.dialogResumeTitle,
        style: SelaText.titleCard.copyWith(color: colors.textPrimary),
      ),
      content: Text(
        l10n.dialogResumeMessage(nextFrame),
        style: SelaText.body.copyWith(color: colors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            l10n.btnRestart,
            style: SelaText.button.copyWith(color: colors.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: SelaRadius.pillBorderRadius,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            l10n.btnResume,
            style: SelaText.button.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
