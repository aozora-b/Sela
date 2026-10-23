// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sela';

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

  @override
  String get titleHistory => 'History';

  @override
  String get emptyHistory => 'No extraction history yet';

  @override
  String get dialogResumeTitle => 'Resume Extraction?';

  @override
  String dialogResumeMessage(int nextFrame) {
    return 'Resume from frame $nextFrame?';
  }

  @override
  String get btnResume => 'Resume';

  @override
  String get btnRestart => 'Restart';

  @override
  String get sessionDeleted => 'History deleted';

  @override
  String historyTotalFrames(int count) {
    return '$count frames';
  }

  @override
  String historyFileSize(String sizeMb) {
    return '±$sizeMb MB';
  }

  @override
  String get titleSettings => 'Settings';

  @override
  String get sectionExtraction => 'Extraction';

  @override
  String get labelFormat => 'File Format';

  @override
  String get labelJpegQuality => 'JPEG Quality';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get titleSelectLanguage => 'Select Language';

  @override
  String get searchLanguage => 'Search language...';

  @override
  String get sectionSuggested => 'Suggested';

  @override
  String get sectionAllLanguages => 'All Languages';

  @override
  String get languageChanged => 'Language changed';

  @override
  String get btnUndo => 'Undo';

  @override
  String get dialogRtlTitle => 'Change Layout (RTL)?';

  @override
  String dialogRtlMessage(String language) {
    return 'Changing to $language will mirror the entire user interface. Continue?';
  }

  @override
  String get btnApply => 'Apply';

  @override
  String get sectionAbout => 'About';
}
