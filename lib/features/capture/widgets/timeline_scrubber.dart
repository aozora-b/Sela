import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_text.dart';
import '../capture_controller.dart';
import 'scrubber_painters.dart';
import 'tick_painter.dart';

class TimelineScrubber extends ConsumerWidget {
  const TimelineScrubber({super.key});

  String _formatTime(double timeS) {
    final m = (timeS / 60).floor().toString().padLeft(2, '0');
    final s = (timeS % 60).floor().toString().padLeft(2, '0');
    return '$m:$s.${((timeS % 1) * 10).floor()}';
  }

  void _seek(
    WidgetRef ref,
    double localDx,
    double width,
    double duration, {
    required bool exact,
  }) {
    final targetTime = (localDx / width).clamp(0.0, 1.0) * duration;
    final oldState = ref.read(captureProvider);
    if ((oldState.currentTime - targetTime).abs() < 0.001) return;

    ref.read(captureProvider.notifier).seekTo(targetTime, exact: exact);

    final minT = math.min(oldState.currentTime, targetTime);
    final maxT = math.max(oldState.currentTime, targetTime);
    final points = oldState.isExactMode
        ? oldState.savedFrames
        : oldState.intervalPoints;

    for (final tick in points) {
      if (tick >= minT && tick <= maxT) {
        HapticFeedback.selectionClick();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(captureProvider);
    if (state.videoInfo == null) return const SizedBox.shrink();

    final duration = state.videoInfo!.durationS;
    if (duration <= 0) return const SizedBox.shrink();

    final currentProgress = state.currentTime / duration;
    final ticks = state.isExactMode
        ? state.savedFrames.toList()
        : state.intervalPoints;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _seek(
              ref,
              details.localPosition.dx,
              constraints.maxWidth,
              duration,
              exact: state.isExactMode,
            ),
            onHorizontalDragStart: (_) {
              ref.read(captureProvider.notifier).setScrubbing(true);
            },
            onHorizontalDragUpdate: (details) => _seek(
              ref,
              details.localPosition.dx,
              constraints.maxWidth,
              duration,
              exact: false,
            ),
            onHorizontalDragEnd: (_) {
              ref.read(captureProvider.notifier).setScrubbing(false);
            },
            onHorizontalDragCancel: () {
              ref.read(captureProvider.notifier).setScrubbing(false);
            },
            child: SizedBox(
              height: 32,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: TrackPainter(
                      progress: currentProgress,
                      trackColor: colors.border,
                      activeTrackColor: colors.accent,
                    ),
                  ),
                  CustomPaint(
                    painter: TickPainter(
                      isExactMode: state.isExactMode,
                      ticks: ticks,
                      duration: duration,
                      accentColor: colors.accent,
                    ),
                  ),
                  CustomPaint(
                    painter: HandlePainter(
                      progress: currentProgress,
                      handleColor: colors.bgElevated,
                      borderColor: colors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(state.currentTime),
              style: SelaText.caption.copyWith(color: colors.textSecondary),
            ),
            Text(
              _formatTime(duration),
              style: SelaText.caption.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
