// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

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
}
