import 'package:flutter/material.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../domain/settings_models.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import '../settings_controller.dart';

class FormatSelectorCard extends StatelessWidget {
  final AppSettings settings;
  final SettingsController notifier;

  const FormatSelectorCard({
    super.key,
    required this.settings,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(SelaSpace.md),
      decoration: const BoxDecoration(
        color: SelaColors.surface,
        borderRadius: SelaRadius.cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.labelFormat, style: SelaText.body),
              SegmentedButton<OutputFormat>(
                segments: const [
                  ButtonSegment(value: OutputFormat.png, label: Text('PNG')),
                  ButtonSegment(value: OutputFormat.jpeg, label: Text('JPEG')),
                ],
                selected: {settings.format},
                onSelectionChanged: (set) => notifier.setFormat(set.first),
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
              ),
            ],
          ),
          if (settings.format == OutputFormat.jpeg) ...[
            const SizedBox(height: SelaSpace.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.labelJpegQuality, style: SelaText.body),
                Text(
                  '${settings.jpegQuality}%',
                  style: SelaText.body.copyWith(color: SelaColors.accent),
                ),
              ],
            ),
            Slider(
              value: settings.jpegQuality.toDouble(),
              min: 1,
              max: 100,
              activeColor: SelaColors.accent,
              inactiveColor: SelaColors.surfaceHighlight,
              onChanged: (val) => notifier.setJpegQuality(val.round()),
            ),
          ],
        ],
      ),
    );
  }
}
