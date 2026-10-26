// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Sela';

  @override
  String get captureModeManual => 'Manuel';

  @override
  String get captureModeInterval => 'Intervalle';

  @override
  String get btnSaveFrame => 'Enregistrer cette image';

  @override
  String get btnSaveMarked => 'Enregistrer toutes les images marquées';

  @override
  String get btnStartExtraction => 'Démarrer l\'extraction';

  @override
  String get intervalCustom => 'Personnalisé';

  @override
  String intervalSeconds(String seconds) {
    return '${seconds}s';
  }

  @override
  String frameEstimate(int count) {
    return '±$count images';
  }

  @override
  String frameIndicator(int current, int total) {
    return 'Image $current / $total';
  }

  @override
  String get errorFailedExtract => 'Échec de l\'extraction de l\'image';

  @override
  String get titleCapture => 'Extraction';

  @override
  String progressFrames(int current, int total) {
    return '$current / $total images';
  }

  @override
  String progressRemaining(String time) {
    return 'Restant $time';
  }

  @override
  String get btnCancel => 'Annuler';

  @override
  String get btnOpenGallery => 'Ouvrir la galerie';

  @override
  String get btnClose => 'Fermer';

  @override
  String extractionComplete(int count) {
    return '$count images enregistrées dans Pictures/Sela';
  }

  @override
  String extractionCancelled(int count) {
    return 'Extraction annulée. $count images enregistrées.';
  }

  @override
  String errorMaxFramesExceeded(int max) {
    return 'Limite maximale de $max images dépassée. Réduisez la durée ou augmentez l\'intervalle.';
  }

  @override
  String get singleFrameSaved => 'Image enregistrée dans Pictures/Sela';

  @override
  String get errorSaveFrame => 'Échec de l\'enregistrement de l\'image';

  @override
  String get titleExtracting => 'Extraction des images...';

  @override
  String get titleHistory => 'Historique';

  @override
  String get emptyHistory => 'Aucun historique d\'extraction';

  @override
  String get dialogResumeTitle => 'Reprendre l\'extraction ?';

  @override
  String dialogResumeMessage(int nextFrame) {
    return 'Continuer à partir de l\'image $nextFrame ?';
  }

  @override
  String get btnResume => 'Reprendre';

  @override
  String get btnRestart => 'Recommencer';

  @override
  String get sessionDeleted => 'Historique supprimé';

  @override
  String historyTotalFrames(int count) {
    return '$count images';
  }

  @override
  String historyFileSize(String sizeMb) {
    return '±$sizeMb Mo';
  }

  @override
  String get titleSettings => 'Paramètres';

  @override
  String get sectionExtraction => 'Extraction';

  @override
  String get labelFormat => 'Format de fichier';

  @override
  String get labelJpegQuality => 'Qualité JPEG';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Système';

  @override
  String get sectionLanguage => 'Langue';

  @override
  String get titleSelectLanguage => 'Sélectionner la langue';

  @override
  String get searchLanguage => 'Rechercher une langue...';

  @override
  String get sectionSuggested => 'Suggéré';

  @override
  String get sectionAllLanguages => 'Toutes les langues';

  @override
  String get languageChanged => 'Langue modifiée';

  @override
  String get btnUndo => 'Annuler';

  @override
  String get dialogRtlTitle => 'Changer la disposition (RTL) ?';

  @override
  String dialogRtlMessage(String language) {
    return 'Passer à $language inversera toute la disposition de l\'interface. Continuer ?';
  }

  @override
  String get btnApply => 'Appliquer';

  @override
  String get sectionAbout => 'À propos';

  @override
  String get titleHome => 'Accueil';

  @override
  String get btnPickVideo => 'Choisir une vidéo';

  @override
  String get homeHeadline => 'Capturez des moments\nde vos vidéos.';

  @override
  String get homeSubtitle => 'Extrayez des images fixes avec précision.';

  @override
  String get homePickVideo => 'Sélectionner une vidéo';

  @override
  String get homeSupportedFormats => 'MP4 · MOV · MKV · WEBM';

  @override
  String get homePickFolder => 'Sélectionner un dossier';

  @override
  String get tabExtract => 'Extraire';

  @override
  String get titleResults => 'Résultats';

  @override
  String get btnSelectAll => 'Tout sélectionner';

  @override
  String get btnDeselectAll => 'Tout désélectionner';

  @override
  String get btnSaveToGallery => 'Enregistrer dans la galerie';

  @override
  String get btnShare => 'Partager';

  @override
  String get btnViewResults => 'Voir les résultats';

  @override
  String resultsSelectedCount(int count, String sizeMb) {
    return '$count images · $sizeMb Mo';
  }

  @override
  String get folderPickNotice =>
      'La sélection de dossier sera disponible dans une prochaine mise à jour';

  @override
  String get titleDeleteSession => 'Supprimer l\'historique';

  @override
  String get confirmDeleteSession =>
      'Voulez-vous vraiment supprimer cet élément de l\'historique ?';

  @override
  String get btnDelete => 'Supprimer';

  @override
  String get customIntervalTitle => 'Définir l\'intervalle';

  @override
  String get customIntervalHint => 'Secondes (ex. 0.1 ou 3)';

  @override
  String titlePhotos(int count) {
    return 'Photos ($count)';
  }

  @override
  String get resultsSubtitle => 'Appuyez pour sélectionner des photos';

  @override
  String get btnSaveAll => 'Tout enregistrer';

  @override
  String get btnSaveSelected => 'Enregistrer la sélection';

  @override
  String savedToFolder(int count, String folder) {
    return '$count images enregistrées dans $folder';
  }

  @override
  String get errorSharePhotos => 'Échec du partage des photos';

  @override
  String get sectionStorage => 'Stockage et dossier';

  @override
  String get labelOrganizeByVideo => 'Organiser par vidéo';

  @override
  String get subOrganizeByVideo =>
      'Crée automatiquement un sous-dossier correspondant au nom de la vidéo pour garder les images bien rangées.';

  @override
  String get labelPickFolder => 'Sélectionner le dossier de destination';

  @override
  String get tooltipResetDefault => 'Réinitialiser par défaut';

  @override
  String storageFolderChanged(String path) {
    return 'Dossier de stockage modifié vers $path';
  }

  @override
  String titleSelectVideoCount(int count) {
    return 'Sélectionner une vidéo ($count)';
  }
}
