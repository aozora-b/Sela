import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TickPainter extends CustomPainter {
  final bool isExactMode;
  final List<double> ticks;
  final double duration;
  final Color accentColor;

  const TickPainter({
    required this.isExactMode,
    required this.ticks,
    required this.duration,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (duration <= 0 || ticks.isEmpty) return;
    final cy = size.height / 2;

    if (isExactMode) {
      final paint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill;
      for (final t in ticks) {
        final x = (t / duration).clamp(0.0, 1.0) * size.width;
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, cy), width: 2.0, height: 10.0),
          paint,
        );
      }
    } else {
      final paint = Paint()
        ..color = accentColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      for (final t in ticks) {
        final x = (t / duration).clamp(0.0, 1.0) * size.width;
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, cy), width: 1.0, height: 8.0),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant TickPainter old) =>
      old.isExactMode != isExactMode ||
      old.duration != duration ||
      old.accentColor != accentColor ||
      !listEquals(old.ticks, ticks);
}
