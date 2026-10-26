import 'package:flutter/material.dart';

class SelaColorsData {
  final Color bg;
  final Color bgElevated;
  final Color surface;
  final Color surfaceHighlight;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color accentSoft;
  final Color error;

  const SelaColorsData({
    required this.bg,
    required this.bgElevated,
    required this.surface,
    required this.surfaceHighlight,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.accentSoft,
    required this.error,
  });

  static const dark = SelaColorsData(
    bg: Color(0xFF17120F),
    bgElevated: Color(0xFF221B17),
    surface: Color(0xFF2B2420),
    surfaceHighlight: Color(0xFF352D28),
    border: Color(0xFF3A312B),
    textPrimary: Color(0xFFF3EDE3),
    textSecondary: Color(0xFFA2968B),
    accent: Color(0xFFC4693F),
    accentSoft: Color(0xFF2B1D17),
    error: Color(0xFFD9534F),
  );

  static const light = SelaColorsData(
    bg: Color(0xFFF9F6F0),
    bgElevated: Color(0xFFFFFFFF),
    surface: Color(0xFFF0EAE1),
    surfaceHighlight: Color(0xFFE6DEC9),
    border: Color(0xFFDDD3C7),
    textPrimary: Color(0xFF1F1813),
    textSecondary: Color(0xFF6B5F54),
    accent: Color(0xFFC4693F),
    accentSoft: Color(0xFFFBECE5),
    error: Color(0xFFD9534F),
  );
}

extension SelaColorsX on BuildContext {
  SelaColorsData get colors => SelaColors.of(this);
}

/// Sela design token color palette across light and dark themes.
abstract final class SelaColors {
  static const Color bg = Color(0xFF17120F);
  static const Color bgElevated = Color(0xFF221B17);
  static const Color surface = Color(0xFF2B2420);
  static const Color surfaceHighlight = Color(0xFF352D28);
  static const Color border = Color(0xFF3A312B);
  static const Color textPrimary = Color(0xFFF3EDE3);
  static const Color textSecondary = Color(0xFFA2968B);
  static const Color accent = Color(0xFFC4693F);
  static const Color accentSoft = Color(0xFF2B1D17);
  static const Color error = Color(0xFFD9534F);

  static const Color bgLight = Color(0xFFF9F6F0);
  static const Color bgElevatedLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF0EAE1);
  static const Color surfaceHighlightLight = Color(0xFFE6DEC9);
  static const Color borderLight = Color(0xFFDDD3C7);
  static const Color textPrimaryLight = Color(0xFF1F1813);
  static const Color textSecondaryLight = Color(0xFF6B5F54);

  /// Resolves the active [SelaColorsData] from the context's theme brightness.
  static SelaColorsData of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? SelaColorsData.dark
        : SelaColorsData.light;
  }
}
