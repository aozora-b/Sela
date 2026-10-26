import 'package:flutter/material.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import 'dashed_border_painter.dart';

/// Kartu area drop/pilih video dengan batas garis putus-putus terracotta.
class ImportDropZone extends StatelessWidget {
  const ImportDropZone({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      label: l10n.homePickVideo,
      child: Material(
        color: colors.bgElevated,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: CustomPaint(
            painter: DashedBorderPainter(
              color: colors.accent.withValues(alpha: 0.85),
              radius: 20,
              strokeWidth: 1.5,
              dashWidth: 6,
              dashGap: 4,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: SelaSpace.xxl,
                horizontal: SelaSpace.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.video_library_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: SelaSpace.lg),
                  Text(
                    l10n.homePickVideo,
                    style: SelaText.of(context, SelaText.titleCard).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SelaSpace.xs),
                  Text(
                    l10n.homeSupportedFormats,
                    style: SelaText.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
