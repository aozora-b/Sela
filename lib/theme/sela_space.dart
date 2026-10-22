import 'package:flutter/material.dart';

/// Sistem jarak dan radius Sela yang adaptif.
abstract final class SelaSpace {
  /// 4.0 dp — Spasi mikro antar ikon dan teks pendukung.
  static const double xs = 4.0;

  /// 8.0 dp — Jarak rapat, gap antar thumbnail.
  static const double sm = 8.0;

  /// 12.0 dp — Padding kartu ringkas.
  static const double md = 12.0;

  /// 16.0 dp — Spasi standar antar seksi kontrol.
  static const double lg = 16.0;

  /// 24.0 dp — Margin horizontal standar layar ponsel.
  static const double xl = 24.0;

  /// 32.0 dp — Spasi vertikal antar blok besar.
  static const double xxl = 32.0;

  /// Inset standar horizontal layar.
  static const EdgeInsetsDirectional screenHorizontal =
      EdgeInsetsDirectional.symmetric(horizontal: xl);
}

/// Token radius sudut Sela.
abstract final class SelaRadius {
  /// 8.0 dp — Radius thumbnail filmstrip / badge kecil.
  static const double sm = 8.0;

  /// 16.0 dp — Radius kartu standar, input field, dialog.
  static const double card = 16.0;

  /// 24.0 dp — Radius sudut atas modal bottom sheet.
  static const double sheet = 24.0;

  /// 999.0 dp — Bentuk kapsul penuh untuk tombol dan chip.
  static const double pill = 999.0;

  /// BorderRadius kartu standar.
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(card),
  );

  /// BorderRadius kapsul (Pill).
  static const BorderRadius pillBorderRadius = BorderRadius.all(
    Radius.circular(pill),
  );

  /// BorderRadius modal bottom sheet (hanya atas).
  static const BorderRadius sheetBorderRadius = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}
