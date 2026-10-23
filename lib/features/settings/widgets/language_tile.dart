import 'package:flutter/material.dart';

import '../../../domain/language_models.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';

class LanguageTile extends StatelessWidget {
  final AppLanguage lang;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageTile({
    super.key,
    required this.lang,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Row(
        children: [
          Text(
            lang.nativeName,
            style: SelaText.body.copyWith(color: colors.textPrimary),
          ),
          if (lang.isRtl) ...[
            const SizedBox(width: SelaSpace.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SelaSpace.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceHighlight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'RTL',
                style: SelaText.caption.copyWith(
                  color: colors.accent,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        lang.englishName,
        style: SelaText.caption.copyWith(color: colors.textSecondary),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: colors.accent)
          : null,
    );
  }
}
