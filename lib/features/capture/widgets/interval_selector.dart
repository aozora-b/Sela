import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import '../capture_controller.dart';

class IntervalSelector extends ConsumerWidget {
  const IntervalSelector({super.key});

  static const _presets = [0.25, 0.5, 1.0, 2.0, 5.0];

  void _showCustomDialog(BuildContext context, WidgetRef ref, double current) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final init = current == current.roundToDouble()
        ? current.toStringAsFixed(0)
        : current.toString();
    final ctrl = TextEditingController(text: init);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.bgElevated,
        shape: const RoundedRectangleBorder(borderRadius: SelaRadius.cardBorderRadius),
        title: Text(l10n.customIntervalTitle, style: SelaText.titleCard),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: SelaSpace.xs,
              children: [0.1, 0.2, 3.0, 10.0, 30.0].map((v) {
                final txt = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
                return ActionChip(
                  label: Text('${txt}s'),
                  onPressed: () => ctrl.text = txt,
                  backgroundColor: colors.surface,
                );
              }).toList(),
            ),
            const SizedBox(height: SelaSpace.md),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: SelaText.body.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.customIntervalHint,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.btnCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.accent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final p = double.tryParse(ctrl.text.replaceAll(',', '.'));
              if (p != null && p > 0 && p <= 3600) {
                ref.read(captureProvider.notifier).selectInterval(p);
                Navigator.pop(ctx);
              }
            },
            child: Text(l10n.btnApply),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final isCustom = !_presets.contains(state.selectedInterval);
    final customLabel = isCustom
        ? l10n.intervalSeconds(
            state.selectedInterval == state.selectedInterval.roundToDouble()
                ? state.selectedInterval.toStringAsFixed(0)
                : state.selectedInterval.toString(),
          )
        : l10n.intervalCustom;

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
              for (final val in _presets) ...[
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
                label: customLabel,
                isActive: isCustom,
                onTap: () => _showCustomDialog(context, ref, state.selectedInterval),
              ),
            ],
          ),
        ),
        const SizedBox(height: SelaSpace.lg),
        Text(
          l10n.frameEstimate(state.estimatedFrameCount),
          style: SelaText.body.copyWith(color: colors.textSecondary),
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
    final colors = context.colors;

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
          color: isActive ? colors.accent : colors.surface,
          borderRadius: SelaRadius.pillBorderRadius,
        ),
        child: Text(
          label,
          style: SelaText.button.copyWith(
            color: isActive ? Colors.white : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
