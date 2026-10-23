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

  @override
  String progressFrames(int current, int total) {
    return '$current / $total frames';
  }

  @override
  String progressRemaining(String time) {
    return 'Remaining $time';
  }

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnOpenGallery => 'Open Gallery';

  @override
  String get btnClose => 'Close';

  @override
  String extractionComplete(int count) {
    return '$count frames saved to Pictures/Sela';
  }

  @override
  String extractionCancelled(int count) {
    return 'Extraction cancelled. $count frames saved.';
  }

  @override
  String errorMaxFramesExceeded(int max) {
    return 'Maximum limit of $max frames exceeded. Reduce duration or increase interval.';
  }

  @override
  String get singleFrameSaved => 'Frame saved to Pictures/Sela';

  @override
  String get errorSaveFrame => 'Failed to save frame';

  @override
  String get titleExtracting => 'Extracting frames...';
}
