import 'package:flutter/material.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_text.dart';

/// Secondary outlined button triggering folder picker.
class PickFolderButton extends StatelessWidget {
  const PickFolderButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: colors.textPrimary,
        ),
        icon: Icon(Icons.folder_outlined, color: colors.textSecondary),
        label: Text(
          l10n.homePickFolder,
          style: SelaText.button.copyWith(color: colors.textPrimary),
        ),
      ),
    );
  }
}
