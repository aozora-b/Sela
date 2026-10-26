import 'package:flutter/material.dart';

import 'sela_colors.dart';

/// Typography styles defining Sela's editorial display serif and UI sans scales.
abstract final class SelaText {
  static const String serifFamily = 'PlayfairDisplay';
  static const String sansFamily = 'Inter';

  static const TextStyle displaySerif = TextStyle(
    fontFamily: serifFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w400,
    height: 1.15,
  );

  static const TextStyle progressNumber = TextStyle(
    fontFamily: serifFamily,
    fontSize: 48.0,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  static const TextStyle titleCard = TextStyle(
    fontFamily: sansFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle button = TextStyle(
    fontFamily: sansFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontFamily: sansFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  /// Resolves [style] with the foreground color corresponding to the active theme.
  static TextStyle of(
    BuildContext context,
    TextStyle style, {
    bool isSecondary = false,
  }) {
    final colors = SelaColors.of(context);
    return style.copyWith(
      color: isSecondary ? colors.textSecondary : colors.textPrimary,
    );
  }
}
