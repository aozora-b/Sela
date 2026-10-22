import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

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

    return Padding(
      padding: SelaSpace.screenHorizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SelaColors.accent,
                foregroundColor: SelaColors.textPrimary,
                shape: const RoundedRectangleBorder(
                  borderRadius: SelaRadius.pillBorderRadius,
                ),
              ),
              onPressed: () {
                if (state.isExactMode) {
                  ref.read(captureProvider.notifier).saveCurrentFrame();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.singleFrameSaved)),
                  );
                } else {
                  ProgressSheet.show(context);
                  ref.read(captureProvider.notifier).startExtraction();
                }
              },
              child: Text(
                state.isExactMode ? l10n.btnSaveFrame : l10n.btnStartExtraction,
                style: SelaText.button,
              ),
            ),
          ),
          if (state.isExactMode) ...[
            const SizedBox(height: SelaSpace.md),
            TextButton(
              onPressed: () {},
              child: Text(
                l10n.btnSaveMarked,
                style: SelaText.button.copyWith(color: SelaColors.accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
