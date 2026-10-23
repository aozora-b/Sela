import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import '../capture_controller.dart';

class ModeSwitch extends ConsumerWidget {
  const ModeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Container(
      margin: SelaSpace.screenHorizontal,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SelaRadius.pillBorderRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ref.read(captureProvider.notifier).toggleMode(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: SelaSpace.md),
                decoration: BoxDecoration(
                  color: state.isExactMode
                      ? colors.textPrimary
                      : Colors.transparent,
                  borderRadius: SelaRadius.pillBorderRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.captureModeManual,
                  style: SelaText.button.copyWith(
                    color: state.isExactMode ? colors.bg : colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ref.read(captureProvider.notifier).toggleMode(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: SelaSpace.md),
                decoration: BoxDecoration(
                  color: !state.isExactMode
                      ? colors.textPrimary
                      : Colors.transparent,
                  borderRadius: SelaRadius.pillBorderRadius,
                ),
                alignment: Alignment.center,
                child: Text(
                  l10n.captureModeInterval,
                  style: SelaText.button.copyWith(
                    color: !state.isExactMode
                        ? colors.bg
                        : colors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
