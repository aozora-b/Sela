// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get captureModeManual => 'Manual';

  @override
  String get captureModeInterval => 'Interval';

  @override
  String get btnSaveFrame => 'Save This Frame';

  @override
  String get btnSaveMarked => 'Save All Marked Frames';

  @override
  String get btnStartExtraction => 'Start Extraction';

  @override
  String get intervalCustom => 'Custom';

  @override
  String intervalSeconds(String seconds) {
    return '${seconds}s';
  }

  @override
  String frameEstimate(int count, String sizeMb) {
    return '±$count frames · ±$sizeMb MB';
  }

  @override
  String frameIndicator(int current, int total) {
    return 'Frame $current / $total';
  }

  @override
  String get errorFailedExtract => 'Failed to extract frame';

  @override
  String get titleCapture => 'Extraction';
}
