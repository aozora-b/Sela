import 'package:flutter/material.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import '../../capture/capture_controller.dart';
import '../../results/results_screen.dart';
import '../extraction_progress_state.dart';

class ProgressActions extends StatelessWidget {
  const ProgressActions({
    required this.progress,
    required this.controller,
    super.key,
  });

  final ExtractionProgressState progress;
  final CaptureController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    if (progress.isExtracting) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.surfaceHighlight),
            shape: const RoundedRectangleBorder(
              borderRadius: SelaRadius.pillBorderRadius,
            ),
          ),
          onPressed: () => controller.cancelExtraction(),
          child: Text(
            l10n.btnCancel,
            style: SelaText.button.copyWith(color: colors.textPrimary),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (progress.isCompleted) ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: SelaRadius.pillBorderRadius,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ResultsScreen(),
                  ),
                );
              },
              child: Text(
                l10n.btnViewResults,
                style: SelaText.button.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: SelaSpace.sm),
        ],
        Row(
          children: [
            if (progress.isCompleted)
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.surfaceHighlight),
                      shape: const RoundedRectangleBorder(
                        borderRadius: SelaRadius.pillBorderRadius,
                      ),
                    ),
                    onPressed: () {
                      controller.openGallery();
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.btnOpenGallery),
                  ),
                ),
              ),
            if (progress.isCompleted) const SizedBox(width: SelaSpace.md),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.surfaceHighlight),
                    shape: const RoundedRectangleBorder(
                      borderRadius: SelaRadius.pillBorderRadius,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.btnClose),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
