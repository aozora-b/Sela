// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Sela';

  @override
  String get captureModeManual => 'Manual';

  @override
  String get captureModeInterval => 'Interval';

  @override
  String get btnSaveFrame => 'Simpan Frame Ini';

  @override
  String get btnSaveMarked => 'Simpan Semua Frame Ditandai';

  @override
  String get btnStartExtraction => 'Mulai Ekstraksi';

  @override
  String get intervalCustom => 'Atur';

  @override
  String intervalSeconds(String seconds) {
    return '$seconds dtk';
  }

  @override
  String frameEstimate(int count, String sizeMb) {
    return '±$count frame · ±$sizeMb MB';
  }

  @override
  String frameIndicator(int current, int total) {
    return 'Frame $current / $total';
  }

  @override
  String get errorFailedExtract => 'Gagal mengambil frame';

  @override
  String get titleCapture => 'Ekstraksi';

  @override
  String progressFrames(int current, int total) {
    return '$current / $total frame';
  }

  @override
  String progressRemaining(String time) {
    return 'Sisa $time';
  }

  @override
  String get btnCancel => 'Batalkan';

  @override
  String get btnOpenGallery => 'Buka Galeri';

  @override
  String get btnClose => 'Tutup';

  @override
  String extractionComplete(int count) {
    return '$count frame tersimpan di Pictures/Sela';
  }

  @override
  String extractionCancelled(int count) {
    return 'Ekstraksi dibatalkan. $count frame tersimpan.';
  }

  @override
  String errorMaxFramesExceeded(int max) {
    return 'Batas maksimum $max frame terlampaui. Kurangi durasi atau perbesar interval.';
  }

  @override
  String get singleFrameSaved => 'Frame tersimpan di Pictures/Sela';

  @override
  String get errorSaveFrame => 'Gagal menyimpan frame';

  @override
  String get titleExtracting => 'Mengekstrak frame...';

  @override
  String get titleHistory => 'Riwayat';

  @override
  String get emptyHistory => 'Belum ada riwayat ekstraksi';

  @override
  String get dialogResumeTitle => 'Lanjutkan Ekstraksi?';

  @override
  String dialogResumeMessage(int nextFrame) {
    return 'Lanjutkan dari frame $nextFrame?';
  }

  @override
  String get btnResume => 'Lanjutkan';

  @override
  String get btnRestart => 'Mulai Ulang';

  @override
  String get sessionDeleted => 'Riwayat dihapus';

  @override
  String historyTotalFrames(int count) {
    return '$count frame';
  }

  @override
  String historyFileSize(String sizeMb) {
    return '±$sizeMb MB';
  }

  @override
  String get titleSettings => 'Setelan';

  @override
  String get sectionExtraction => 'Ekstraksi';

  @override
  String get labelFormat => 'Format Berkas';

  @override
  String get labelJpegQuality => 'Kualitas JPEG';

  @override
  String get sectionAppearance => 'Tampilan';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get sectionLanguage => 'Bahasa';

  @override
  String get titleSelectLanguage => 'Pilih Bahasa';

  @override
  String get searchLanguage => 'Cari bahasa...';

  @override
  String get sectionSuggested => 'Disarankan';

  @override
  String get sectionAllLanguages => 'Semua Bahasa';

  @override
  String get languageChanged => 'Bahasa diubah';

  @override
  String get btnUndo => 'Urungkan';

  @override
  String get dialogRtlTitle => 'Ubah Tata Letak (RTL)?';

  @override
  String dialogRtlMessage(String language) {
    return 'Mengubah ke $language akan mencerminkan seluruh tata letak antarmuka. Lanjutkan?';
  }

  @override
  String get btnApply => 'Terapkan';

  @override
  String get sectionAbout => 'Tentang';
}
