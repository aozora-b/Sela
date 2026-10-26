import 'package:flutter/material.dart';

/// Layout spacing design tokens.
abstract final class SelaSpace {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  static const EdgeInsetsDirectional screenHorizontal =
      EdgeInsetsDirectional.symmetric(horizontal: xl);
}

/// Corner radius design tokens.
abstract final class SelaRadius {
  static const double sm = 8.0;
  static const double card = 16.0;
  static const double sheet = 24.0;
  static const double pill = 999.0;

  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(card),
  );

  static const BorderRadius pillBorderRadius = BorderRadius.all(
    Radius.circular(pill),
  );

  static const BorderRadius sheetBorderRadius = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}
