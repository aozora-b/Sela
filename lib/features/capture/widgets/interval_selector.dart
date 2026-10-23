import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import '../capture_controller.dart';

class IntervalSelector extends ConsumerWidget {
  const IntervalSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final l10n = AppLocalizations.of(context)!;

    final intervals = [0.25, 0.5, 1.0, 2.0, 5.0];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.only(
            start: SelaSpace.xl,
            end: SelaSpace.lg,
          ),
          child: Row(
            children: [
              for (final val in intervals) ...[
                _IntervalChip(
                  label: l10n.intervalSeconds(
                    val == val.roundToDouble()
                        ? val.toStringAsFixed(0)
                        : val.toString(),
                  ),
                  isActive: state.selectedInterval == val,
                  onTap: () =>
                      ref.read(captureProvider.notifier).selectInterval(val),
                ),
                const SizedBox(width: SelaSpace.sm),
              ],
              _IntervalChip(
                label: l10n.intervalCustom,
                isActive: false,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: SelaSpace.lg),
        Text(
          l10n.frameEstimate(state.estimatedFrameCount, state.estimatedSizeMb),
          style: SelaText.body,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _IntervalChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _IntervalChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: SelaSpace.lg,
          vertical: SelaSpace.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? SelaColors.accent : SelaColors.surface,
          borderRadius: SelaRadius.pillBorderRadius,
        ),
        child: Text(
          label,
          style: SelaText.button.copyWith(
            color: isActive ? SelaColors.textPrimary : SelaColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
