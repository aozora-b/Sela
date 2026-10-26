import 'package:flutter/material.dart';

class TrackPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color activeTrackColor;

  const TrackPainter({
    required this.progress,
    required this.trackColor,
    required this.activeTrackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    const r = Radius.circular(2);
    canvas.drawRRect(
      RRect.fromLTRBR(0, cy - 2, size.width, cy + 2, r),
      Paint()..color = trackColor,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(
        0,
        cy - 2,
        size.width * progress.clamp(0.0, 1.0),
        cy + 2,
        r,
      ),
      Paint()..color = activeTrackColor,
    );
  }

  @override
  bool shouldRepaint(covariant TrackPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.activeTrackColor != activeTrackColor;
}

class HandlePainter extends CustomPainter {
  final double progress;
  final Color handleColor;
  final Color borderColor;

  const HandlePainter({
    required this.progress,
    required this.handleColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      progress.clamp(0.0, 1.0) * size.width,
      size.height / 2,
    );
    canvas.drawCircle(center, 10, Paint()..color = handleColor);
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant HandlePainter old) =>
      old.progress != progress ||
      old.handleColor != handleColor ||
      old.borderColor != borderColor;
}
