import 'package:flutter/material.dart';

/// Palet warna resmi Sela (Editorial Dark Aesthetic).
abstract final class SelaColors {
  /// Latar belakang kanvas utama (Deep Espresso).
  static const Color bg = Color(0xFF17120F);

  /// Latar belakang kontainer melayang, modal sheet, navbar.
  static const Color bgElevated = Color(0xFF221B17);

  /// Warna permukaan kartu, panel kontrol, baris setelan.
  static const Color surface = Color(0xFF2B2420);

  /// Warna kartu saat disentuh / dipilih.
  static const Color surfaceHighlight = Color(0xFF352D28);

  /// Garis pembatas subtil 1px.
  static const Color border = Color(0xFF3A312B);

  /// Teks utama, judul, angka aktif (Warm Cream).
  static const Color textPrimary = Color(0xFFF3EDE3);

  /// Teks sekunder, label, subjudul, metadata (Muted Taupe).
  static const Color textSecondary = Color(0xFFA2968B);

  /// Aksen utama: tombol CTA, toggle aktif, penanda frame (Terracotta).
  static const Color accent = Color(0xFFC4693F);

  /// Latar belakang lembut chip aksen.
  static const Color accentSoft = Color(0xFF2B1D17);

  /// Indikator galat / pembatalan.
  static const Color error = Color(0xFFD9534F);
}
