import 'package:flutter/material.dart';

/// Palet warna resmi Sela (Editorial Aesthetic: Dark & Light).
abstract final class SelaColors {
  /// Dark: Latar belakang kanvas utama (Deep Espresso).
  static const Color bg = Color(0xFF17120F);

  /// Dark: Latar belakang kontainer melayang, modal sheet, navbar.
  static const Color bgElevated = Color(0xFF221B17);

  /// Dark: Warna permukaan kartu, panel kontrol, baris setelan.
  static const Color surface = Color(0xFF2B2420);

  /// Dark: Warna kartu saat disentuh / dipilih.
  static const Color surfaceHighlight = Color(0xFF352D28);

  /// Dark: Garis pembatas subtil 1px.
  static const Color border = Color(0xFF3A312B);

  /// Dark: Teks utama, judul, angka aktif (Warm Cream).
  static const Color textPrimary = Color(0xFFF3EDE3);

  /// Dark: Teks sekunder, label, subjudul, metadata (Muted Taupe).
  static const Color textSecondary = Color(0xFFA2968B);

  /// Aksen utama bersama: tombol CTA, toggle aktif, penanda frame (Terracotta).
  static const Color accent = Color(0xFFC4693F);

  /// Latar belakang lembut chip aksen.
  static const Color accentSoft = Color(0xFF2B1D17);

  /// Indikator galat / pembatalan.
  static const Color error = Color(0xFFD9534F);

  /// Light: Latar belakang kanvas utama (Warm Cream Paper).
  static const Color bgLight = Color(0xFFF9F6F0);

  /// Light: Latar belakang kontainer melayang, modal sheet, navbar.
  static const Color bgElevatedLight = Color(0xFFFFFFFF);

  /// Light: Warna permukaan kartu, panel kontrol, baris setelan.
  static const Color surfaceLight = Color(0xFFF0EAE1);

  /// Light: Warna kartu saat disentuh / dipilih.
  static const Color surfaceHighlightLight = Color(0xFFE6DEC9);

  /// Light: Garis pembatas subtil 1px.
  static const Color borderLight = Color(0xFFDDD3C7);

  /// Light: Teks utama, judul, angka aktif (Ink Espresso).
  static const Color textPrimaryLight = Color(0xFF1F1813);

  /// Light: Teks sekunder, label, subjudul, metadata (Muted Taupe).
  static const Color textSecondaryLight = Color(0xFF6B5F54);
}
