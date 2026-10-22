import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_text.dart';
import '../capture_controller.dart';
import 'tick_painter.dart';

class TimelineScrubber extends ConsumerWidget {
  const TimelineScrubber({super.key});

  String _formatTime(double timeS) {
    final m = (timeS / 60).floor().toString().padLeft(2, '0');
    final s = (timeS % 60).floor().toString().padLeft(2, '0');
    final d = ((timeS % 1) * 10).floor();
    return '$m:$s.$d';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) => _seek(
                ref,
                details.localPosition.dx,
                constraints.maxWidth,
                duration,
              ),
              onHorizontalDragUpdate: (details) => _seek(
                ref,
                details.localPosition.dx,
                constraints.maxWidth,
                duration,
              ),
              child: SizedBox(
                height: 32, // space for 20dp handle
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _TrackPainter(progress: currentProgress),
                    ),
                    CustomPaint(
                      painter: TickPainter(
                        isExactMode: state.isExactMode,
                        ticks: ticks,
                        duration: duration,
                      ),
                    ),
                    CustomPaint(
                      painter: _HandlePainter(progress: currentProgress),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatTime(state.currentTime), style: SelaText.caption),
            Text(_formatTime(duration), style: SelaText.caption),
          ],
        ),
      ],
    );
  }

  void _seek(WidgetRef ref, double localDx, double width, double duration) {
    final percent = (localDx / width).clamp(0.0, 1.0);
    final targetTime = percent * duration;

    final oldState = ref.read(captureProvider);
    if ((oldState.currentTime - targetTime).abs() < 0.001) return;

    ref.read(captureProvider.notifier).seekTo(targetTime);

    final minT = math.min(oldState.currentTime, targetTime);
    final maxT = math.max(oldState.currentTime, targetTime);
    final pointsToCheck = oldState.isExactMode
        ? oldState.savedFrames
        : oldState.intervalPoints;

    for (final tick in pointsToCheck) {
      if (tick >= minT && tick <= maxT) {
        HapticFeedback.selectionClick();
        break;
      }
    }
  }
}

class _TrackPainter extends CustomPainter {
  final double progress;
  const _TrackPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    canvas.drawRRect(
      RRect.fromLTRBR(0, cy - 2, size.width, cy + 2, const Radius.circular(2)),
      Paint()
        ..color = SelaColors.border
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        0,
        cy - 2,
        size.width * progress.clamp(0.0, 1.0),
        cy + 2,
        const Radius.circular(2),
      ),
      Paint()
        ..color = SelaColors.accent
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _TrackPainter old) => old.progress != progress;
}

class _HandlePainter extends CustomPainter {
  final double progress;
  const _HandlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final hx = progress.clamp(0.0, 1.0) * size.width;
    canvas.drawCircle(
      Offset(hx, cy),
      10,
      Paint()..color = SelaColors.textPrimary,
    );
    canvas.drawCircle(
      Offset(hx, cy),
      10,
      Paint()
        ..color = SelaColors.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _HandlePainter old) => old.progress != progress;
}
