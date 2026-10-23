import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../domain/sample_plan.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import '../../progress/progress_sheet.dart';
import '../capture_controller.dart';

class CaptureBottomBar extends ConsumerWidget {
  const CaptureBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Padding(
      padding: SelaSpace.screenHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: SelaRadius.pillBorderRadius,
                ),
              ),
              onPressed: () async {
                if (state.isExactMode) {
                  final uri = await ref
                      .read(captureProvider.notifier)
                      .saveCurrentFrame();
                  if (!context.mounted) return;
                  final msg = uri != null
                      ? l10n.singleFrameSaved
                      : l10n.errorSaveFrame;
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(msg)));
                } else {
                  if (state.estimatedFrameCount > maxFrames) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.errorMaxFramesExceeded(maxFrames)),
                      ),
                    );
                    return;
                  }
                  unawaited(ProgressSheet.show(context));
                  unawaited(
                    ref
                        .read(captureProvider.notifier)
                        .startExtraction(
                          errorMessage: l10n.errorMaxFramesExceeded(maxFrames),
                        ),
                  );
                }
              },
              child: Text(
                state.isExactMode ? l10n.btnSaveFrame : l10n.btnStartExtraction,
                style: SelaText.button.copyWith(color: Colors.white),
              ),
            ),
          ),
          if (state.isExactMode) ...[
            const SizedBox(height: SelaSpace.md),
            TextButton(
              onPressed: state.savedFrames.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.extractionComplete(state.savedFrames.length),
                          ),
                        ),
                      );
                    },
              child: Text(
                l10n.btnSaveMarked,
                style: SelaText.button.copyWith(
                  color: state.savedFrames.isEmpty
                      ? colors.textSecondary
                      : colors.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
