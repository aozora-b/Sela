// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Sela';

  @override
  String get captureModeManual => 'Manuell';

  @override
  String get captureModeInterval => 'Intervall';

  @override
  String get btnSaveFrame => 'Diesen Frame speichern';

  @override
  String get btnSaveMarked => 'Alle markierten Frames speichern';

  @override
  String get btnStartExtraction => 'Extraktion starten';

  @override
  String get intervalCustom => 'Anpassen';

  @override
  String intervalSeconds(String seconds) {
    return '${seconds}s';
  }

  @override
  String frameEstimate(int count) {
    return '±$count Frames';
  }

  @override
  String frameIndicator(int current, int total) {
    return 'Frame $current / $total';
  }

  @override
  String get errorFailedExtract => 'Fehler beim Extrahieren des Frames';

  @override
  String get titleCapture => 'Extraktion';

  @override
  String progressFrames(int current, int total) {
    return '$current / $total Frames';
  }

  @override
  String progressRemaining(String time) {
    return 'Verbleibend $time';
  }

  @override
  String get btnCancel => 'Abbrechen';

  @override
  String get btnOpenGallery => 'Galerie öffnen';

  @override
  String get btnClose => 'Schließen';

  @override
  String extractionComplete(int count) {
    return '$count Frames in Pictures/Sela gespeichert';
  }

  @override
  String extractionCancelled(int count) {
    return 'Extraktion abgebrochen. $count Frames gespeichert.';
  }

  @override
  String errorMaxFramesExceeded(int max) {
    return 'Maximale Grenze von $max Frames überschritten. Dauer reduzieren oder Intervall erhöhen.';
  }

  @override
  String get singleFrameSaved => 'Frame in Pictures/Sela gespeichert';

  @override
  String get errorSaveFrame => 'Fehler beim Speichern des Frames';

  @override
  String get titleExtracting => 'Frames werden extrahiert...';

  @override
  String get titleHistory => 'Verlauf';

  @override
  String get emptyHistory => 'Noch kein Extraktionsverlauf vorhanden';

  @override
  String get dialogResumeTitle => 'Extraktion fortsetzen?';

  @override
  String dialogResumeMessage(int nextFrame) {
    return 'Ab Frame $nextFrame fortfahren?';
  }

  @override
  String get btnResume => 'Fortsetzen';

  @override
  String get btnRestart => 'Neu starten';

  @override
  String get sessionDeleted => 'Verlauf gelöscht';

  @override
  String historyTotalFrames(int count) {
    return '$count Frames';
  }

  @override
  String historyFileSize(String sizeMb) {
    return '±$sizeMb MB';
  }

  @override
  String get titleSettings => 'Einstellungen';

  @override
  String get sectionExtraction => 'Extraktion';

  @override
  String get labelFormat => 'Dateiformat';

  @override
  String get labelJpegQuality => 'JPEG-Qualität';

  @override
  String get sectionAppearance => 'Erscheinungsbild';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeSystem => 'System';

  @override
  String get sectionLanguage => 'Sprache';

  @override
  String get titleSelectLanguage => 'Sprache auswählen';

  @override
  String get searchLanguage => 'Sprache suchen...';

  @override
  String get sectionSuggested => 'Vorgeschlagen';

  @override
  String get sectionAllLanguages => 'Alle Sprachen';

  @override
  String get languageChanged => 'Sprache geändert';

  @override
  String get btnUndo => 'Rückgängig';

  @override
  String get dialogRtlTitle => 'Layout ändern (RTL)?';

  @override
  String dialogRtlMessage(String language) {
    return 'Der Wechsel zu $language spiegelt das gesamte Layout der Benutzeroberfläche. Fortfahren?';
  }

  @override
  String get btnApply => 'Anwenden';

  @override
  String get sectionAbout => 'Über';

  @override
  String get titleHome => 'Startseite';

  @override
  String get btnPickVideo => 'Video auswählen';

  @override
  String get homeHeadline => 'Momente aus\nVideos festhalten.';

  @override
  String get homeSubtitle => 'Standbilder mit Präzision extrahieren.';

  @override
  String get homePickVideo => 'Video auswählen';

  @override
  String get homeSupportedFormats => 'MP4 · MOV · MKV · WEBM';

  @override
  String get homePickFolder => 'Ordner auswählen';

  @override
  String get tabExtract => 'Extrahieren';

  @override
  String get titleResults => 'Ergebnisse';

  @override
  String get btnSelectAll => 'Alle auswählen';

  @override
  String get btnDeselectAll => 'Auswahl aufheben';

  @override
  String get btnSaveToGallery => 'In Galerie speichern';

  @override
  String get btnShare => 'Teilen';

  @override
  String get btnViewResults => 'Ergebnisse anzeigen';

  @override
  String resultsSelectedCount(int count, String sizeMb) {
    return '$count Frames · $sizeMb MB';
  }

  @override
  String get folderPickNotice =>
      'Die Ordnerauswahl wird in einem kommenden Update verfügbar sein';

  @override
  String get titleDeleteSession => 'Verlauf löschen';

  @override
  String get confirmDeleteSession =>
      'Möchten Sie diesen Verlaufseintrag wirklich löschen?';

  @override
  String get btnDelete => 'Löschen';

  @override
  String get customIntervalTitle => 'Intervall festlegen';

  @override
  String get customIntervalHint => 'Sekunden (z. B. 0.1 oder 3)';

  @override
  String titlePhotos(int count) {
    return 'Fotos ($count)';
  }

  @override
  String get resultsSubtitle => 'Tippen, um Fotos auszuwählen';

  @override
  String get btnSaveAll => 'Alle speichern';

  @override
  String get btnSaveSelected => 'Ausgewählte speichern';

  @override
  String savedToFolder(int count, String folder) {
    return '$count Frames in $folder gespeichert';
  }

  @override
  String get errorSharePhotos => 'Fehler beim Teilen der Fotos';

  @override
  String get sectionStorage => 'Speicher & Ordner';

  @override
  String get labelOrganizeByVideo => 'Nach Video gruppieren';

  @override
  String get subOrganizeByVideo =>
      'Erstellt automatisch einen Unterordner mit dem Videonamen, um Frames ordentlich zu halten.';

  @override
  String get labelPickFolder => 'Speicherordner wählen';

  @override
  String get tooltipResetDefault => 'Auf Standard zurücksetzen';

  @override
  String storageFolderChanged(String path) {
    return 'Speicherordner geändert zu $path';
  }

  @override
  String titleSelectVideoCount(int count) {
    return 'Video auswählen ($count)';
  }
}
