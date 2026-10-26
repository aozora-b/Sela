import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _step(WidgetRef ref, CaptureState state, int deltaFrames) {
    final currentFrame = videoInfo.frameForTime(state.currentTime);
    final targetFrame = (currentFrame + deltaFrames).clamp(
      1,
      videoInfo.frameCount,
    );
    final targetTime = videoInfo.timeForFrame(targetFrame);
    ref.read(captureProvider.notifier).seekTo(targetTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final currentFrame = videoInfo.frameForTime(state.currentTime);
    final isMarked = state.markedFrames.contains(currentFrame);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: SelaSpace.screenHorizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NudgeButton(
                label: '-1',
                onTap: () => _step(ref, state, -1),
                onLongPress: () => _step(ref, state, -10),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.frameIndicator(currentFrame, videoInfo.frameCount),
                        style: SelaText.titleCard.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(captureProvider.notifier)
                              .toggleMarkCurrentFrame();
                        },
                        child: Icon(
                          isMarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20,
                          color: isMarked
                              ? colors.accent
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${state.currentTime.toStringAsFixed(2)}s · ${videoInfo.formattedFps}',
                    style: SelaText.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
              _NudgeButton(
                label: '+1',
                onTap: () => _step(ref, state, 1),
                onLongPress: () => _step(ref, state, 10),
              ),
            ],
          ),
        ),
        const SizedBox(height: SelaSpace.lg),
        FrameFilmstrip(videoInfo: videoInfo),
      ],
    );
  }
}

class _NudgeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NudgeButton({
    required this.label,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: SelaText.body.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'frame',
          style: SelaText.caption.copyWith(
            color: colors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
