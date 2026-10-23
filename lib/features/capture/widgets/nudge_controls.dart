import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../domain/models.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import '../capture_controller.dart';
import 'frame_filmstrip.dart';

class NudgeControls extends ConsumerWidget {
  final VideoInfo videoInfo;

  const NudgeControls({super.key, required this.videoInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final currentFrame = ((state.currentTime * videoInfo.fps).round() + 1)
        .clamp(1, videoInfo.frameCount);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: SelaSpace.screenHorizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NudgeButton(
                icon: Icons.remove,
                label: '-1 Frame',
                onTap: () => ref
                    .read(captureProvider.notifier)
                    .seekTo(state.currentTime - (1 / videoInfo.fps)),
                onLongPress: () => ref
                    .read(captureProvider.notifier)
                    .seekTo(state.currentTime - (10 / videoInfo.fps)),
              ),
              Text(
                l10n.frameIndicator(currentFrame, videoInfo.frameCount),
                style: SelaText.titleCard.copyWith(color: colors.textPrimary),
              ),
              _NudgeButton(
                icon: Icons.add,
                label: '+1 Frame',
                onTap: () => ref
                    .read(captureProvider.notifier)
                    .seekTo(state.currentTime + (1 / videoInfo.fps)),
                onLongPress: () => ref
                    .read(captureProvider.notifier)
                    .seekTo(state.currentTime + (10 / videoInfo.fps)),
              ),
            ],
          ),
        ),
        const SizedBox(height: SelaSpace.lg),
        const FrameFilmstrip(),
      ],
    );
  }
}

class _NudgeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NudgeButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: colors.textPrimary, size: 20),
      ),
    );
  }
}
