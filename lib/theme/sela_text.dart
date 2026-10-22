import 'package:flutter/material.dart';
import 'sela_colors.dart';

/// Tipografi resmi Sela (Editorial Serif Display + Clean UI Sans).
abstract final class SelaText {
  /// Font Serif untuk Judul Besar & Angka Progres (Playfair Display / Serif).
  static const String serifFamily = 'PlayfairDisplay';

  /// Font Sans-Serif untuk Teks Antarmuka (Inter / Plus Jakarta Sans).
  static const String sansFamily = 'Inter';

  /// Judul Utama Layar (Serif Editorial 32–34 sp).
  static const TextStyle displaySerif = TextStyle(
    fontFamily: serifFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.w400,
    height: 1.15,
    color: SelaColors.textPrimary,
  );

  /// Angka Progres Besar di tengah Ring (Serif 48 sp).
  static const TextStyle progressNumber = TextStyle(
    fontFamily: serifFamily,
    fontSize: 48.0,
    fontWeight: FontWeight.w400,
    height: 1.0,
    color: SelaColors.textPrimary,
  );

  /// Judul Kartu & Navigasi (Sans 16 sp, Semi-Bold).
  static const TextStyle titleCard = TextStyle(
    fontFamily: sansFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: SelaColors.textPrimary,
  );

  /// Teks Isi Standar (Sans 14 sp).
  static const TextStyle body = TextStyle(
    fontFamily: sansFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: SelaColors.textSecondary,
  );

  /// Label Tombol CTA (Sans 15 sp, Medium).
  static const TextStyle button = TextStyle(
    fontFamily: sansFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: SelaColors.textPrimary,
  );

  /// Label Kategori / Header Seksi Huruf Kapital (Sans 11 sp, Tracked).
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: sansFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: SelaColors.textSecondary,
  );

  /// Metadata Halus & Keterangan Waktu (Sans 12 sp).
  static const TextStyle caption = TextStyle(
    fontFamily: sansFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: SelaColors.textSecondary,
  );
}
