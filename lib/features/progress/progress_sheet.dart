import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../theme/sela_colors.dart';
import '../../theme/sela_space.dart';
import '../../theme/sela_text.dart';
import '../capture/capture_controller.dart';
import 'extraction_progress_controller.dart';

class ProgressSheet extends ConsumerWidget {
  const ProgressSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: SelaColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: SelaRadius.sheetBorderRadius,
      ),
      builder: (_) => const ProgressSheet(),
    );
  }

  String _formatDuration(Duration d) {
    final s = d.inSeconds % 60;
    final m = d.inMinutes;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(extractionProgressProvider);
    final controller = ref.read(captureProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SelaSpace.xl,
          vertical: SelaSpace.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              progress.isCompleted
                  ? l10n.extractionComplete(progress.current)
                  : progress.isCancelled
                  ? l10n.extractionCancelled(progress.current)
                  : progress.error != null
                  ? progress.error!
                  : l10n.titleExtracting,
              style: SelaText.titleCard,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SelaSpace.xl),
            SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress.progressRatio,
                    strokeWidth: 6,
                    backgroundColor: SelaColors.surfaceHighlight,
                    valueColor: const AlwaysStoppedAnimation(SelaColors.accent),
                  ),
                  Text(
                    '${(progress.progressRatio * 100).toInt()}%',
                    style: SelaText.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SelaSpace.lg),
            Text(
              l10n.progressFrames(progress.current, progress.total),
              style: SelaText.body,
            ),
            if (progress.remainingTime != null && progress.isExtracting) ...[
              const SizedBox(height: SelaSpace.xs),
              Text(
                l10n.progressRemaining(
                  _formatDuration(progress.remainingTime!),
                ),
                style: SelaText.caption,
              ),
            ],
            const SizedBox(height: SelaSpace.xl),
            if (progress.isExtracting)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SelaColors.textPrimary,
                    side: const BorderSide(color: SelaColors.surfaceHighlight),
                    shape: const RoundedRectangleBorder(
                      borderRadius: SelaRadius.pillBorderRadius,
                    ),
                  ),
                  onPressed: () => controller.cancelExtraction(),
                  child: Text(l10n.btnCancel, style: SelaText.button),
                ),
              )
            else
              Row(
                children: [
                  if (progress.isCompleted)
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SelaColors.accent,
                            foregroundColor: SelaColors.textPrimary,
                            shape: const RoundedRectangleBorder(
                              borderRadius: SelaRadius.pillBorderRadius,
                            ),
                          ),
                          onPressed: () {
                            controller.openGallery();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            l10n.btnOpenGallery,
                            style: SelaText.button,
                          ),
                        ),
                      ),
                    ),
                  if (progress.isCompleted) const SizedBox(width: SelaSpace.md),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SelaColors.textPrimary,
                          side: const BorderSide(
                            color: SelaColors.surfaceHighlight,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: SelaRadius.pillBorderRadius,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.btnClose, style: SelaText.button),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
