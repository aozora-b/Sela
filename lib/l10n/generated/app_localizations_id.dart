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
  String frameEstimate(int count) {
    return '±$count frame';
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

  @override
  String get titleHome => 'Beranda';

  @override
  String get btnPickVideo => 'Pilih Video';

  @override
  String get homeHeadline => 'Ambil momen\ndari video.';

  @override
  String get homeSubtitle => 'Ekstrak frame diam dengan presisi.';

  @override
  String get homePickVideo => 'Pilih video';

  @override
  String get homeSupportedFormats => 'MP4 · MOV · MKV · WEBM';

  @override
  String get homePickFolder => 'Pilih folder';

  @override
  String get tabExtract => 'Ekstrak';

  @override
  String get titleResults => 'Hasil';

  @override
  String get btnSelectAll => 'Pilih semua';

  @override
  String get btnDeselectAll => 'Batal pilih';

  @override
  String get btnSaveToGallery => 'Simpan ke Galeri';

  @override
  String get btnShare => 'Bagikan';

  @override
  String get btnViewResults => 'Lihat Hasil';

  @override
  String resultsSelectedCount(int count, String sizeMb) {
    return '$count frame · $sizeMb MB';
  }

  @override
  String get folderPickNotice =>
      'Pemilihan folder akan hadir pada pembaruan mendatang';

  @override
  String get titleDeleteSession => 'Hapus Riwayat';

  @override
  String get confirmDeleteSession =>
      'Apakah Anda yakin ingin menghapus riwayat ini?';

  @override
  String get btnDelete => 'Hapus';

  @override
  String get customIntervalTitle => 'Atur Interval';

  @override
  String get customIntervalHint => 'Detik (contoh: 0.1 atau 3)';

  @override
  String titlePhotos(int count) {
    return 'Foto ($count)';
  }

  @override
  String get resultsSubtitle => 'Ketuk untuk memilih foto';

  @override
  String get btnSaveAll => 'Simpan Semua';

  @override
  String get btnSaveSelected => 'Simpan yang Dipilih';

  @override
  String savedToFolder(int count, String folder) {
    return '$count frame tersimpan di $folder';
  }

  @override
  String get errorSharePhotos => 'Gagal membagikan foto';

  @override
  String get sectionStorage => 'Penyimpanan & Folder';

  @override
  String get labelOrganizeByVideo => 'Kelompokkan per Video';

  @override
  String get subOrganizeByVideo =>
      'Otomatis membuat subfolder sesuai nama video agar ribuan frame tetap rapi.';

  @override
  String get labelPickFolder => 'Pilih Folder Penyimpanan';

  @override
  String get tooltipResetDefault => 'Kembalikan ke Default';

  @override
  String storageFolderChanged(String path) {
    return 'Folder penyimpanan diubah ke $path';
  }

  @override
  String titleSelectVideoCount(int count) {
    return 'Pilih Video ($count)';
  }
}
