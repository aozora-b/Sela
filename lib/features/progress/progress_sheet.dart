import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../theme/sela_colors.dart';
import '../../theme/sela_space.dart';
import '../../theme/sela_text.dart';
import '../capture/capture_controller.dart';
import '../results/results_screen.dart';
import 'extraction_progress_controller.dart';
import 'widgets/progress_actions.dart';

class ProgressSheet extends ConsumerWidget {
  const ProgressSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: context.colors.bgElevated,
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
    ref.listen(extractionProgressProvider, (prev, next) {
      if ((prev == null || !prev.isCompleted) && next.isCompleted) {
        // Otomatis pindah ke halaman hasil (ResultsScreen) setelah selesai
        Future.microtask(() {
          if (!context.mounted) return;
          final navigator = Navigator.of(context);
          navigator.pop(); // Tutup progress sheet
          navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => const ResultsScreen(),
            ),
          );
        });
      }
    });

    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(extractionProgressProvider);
    final controller = ref.read(captureProvider.notifier);
    final colors = context.colors;

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
              style: SelaText.titleCard.copyWith(color: colors.textPrimary),
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
                    backgroundColor: colors.surfaceHighlight,
                    valueColor: AlwaysStoppedAnimation(colors.accent),
                  ),
                  Text(
                    '${(progress.progressRatio * 100).toInt()}%',
                    style: SelaText.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SelaSpace.lg),
            Text(
              l10n.progressFrames(progress.current, progress.total),
              style: SelaText.body.copyWith(color: colors.textSecondary),
            ),
            if (progress.remainingTime != null && progress.isExtracting) ...[
              const SizedBox(height: SelaSpace.xs),
              Text(
                l10n.progressRemaining(
                  _formatDuration(progress.remainingTime!),
                ),
                style: SelaText.caption.copyWith(color: colors.textSecondary),
              ),
            ],
            const SizedBox(height: SelaSpace.xl),
            ProgressActions(progress: progress, controller: controller),
          ],
        ),
      ),
    );
  }
}
