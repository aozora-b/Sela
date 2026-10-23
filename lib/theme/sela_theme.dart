import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'sela_colors.dart';
import 'sela_space.dart';
import 'sela_text.dart';

export 'sela_colors.dart';
export 'sela_space.dart';
export 'sela_text.dart';

/// Tema global ThemeData untuk Sela.
abstract final class SelaTheme {
  /// ThemeData Gelap Resmi Sela (Editorial Dark).
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SelaColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: SelaColors.accent,
        onPrimary: SelaColors.textPrimary,
        surface: SelaColors.surface,
        onSurface: SelaColors.textPrimary,
        error: SelaColors.error,
        onError: SelaColors.textPrimary,
        outline: SelaColors.border,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: SelaText.displaySerif,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SelaColors.accent,
          foregroundColor: SelaColors.textPrimary,
          minimumSize: const Size.fromHeight(56.0),
          shape: const RoundedRectangleBorder(
            borderRadius: SelaRadius.pillBorderRadius,
          ),
          textStyle: SelaText.button,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SelaColors.textPrimary,
          minimumSize: const Size.fromHeight(48.0),
          side: const BorderSide(color: SelaColors.border, width: 1.0),
          shape: const RoundedRectangleBorder(
            borderRadius: SelaRadius.pillBorderRadius,
          ),
          textStyle: SelaText.button,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SelaColors.bgElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: SelaRadius.sheetBorderRadius,
        ),
        dragHandleColor: SelaColors.border,
        dragHandleSize: Size(40, 4),
        showDragHandle: true,
      ),
      dividerTheme: const DividerThemeData(
        color: SelaColors.border,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }

  /// ThemeData Terang Resmi Sela (Editorial Light).
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: SelaColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: SelaColors.accent,
        onPrimary: Colors.white,
        surface: SelaColors.surfaceLight,
        onSurface: SelaColors.textPrimaryLight,
        error: SelaColors.error,
        onError: Colors.white,
        outline: SelaColors.borderLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: SelaText.displaySerif,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SelaColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56.0),
          shape: const RoundedRectangleBorder(
            borderRadius: SelaRadius.pillBorderRadius,
          ),
          textStyle: SelaText.button,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SelaColors.textPrimaryLight,
          minimumSize: const Size.fromHeight(48.0),
          side: const BorderSide(color: SelaColors.borderLight, width: 1.0),
          shape: const RoundedRectangleBorder(
            borderRadius: SelaRadius.pillBorderRadius,
          ),
          textStyle: SelaText.button,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SelaColors.bgElevatedLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: SelaRadius.sheetBorderRadius,
        ),
        dragHandleColor: SelaColors.borderLight,
        dragHandleSize: Size(40, 4),
        showDragHandle: true,
      ),
      dividerTheme: const DividerThemeData(
        color: SelaColors.borderLight,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}
