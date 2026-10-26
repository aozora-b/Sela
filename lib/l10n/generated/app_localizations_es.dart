// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Sela';

  @override
  String get captureModeManual => 'Manual';

  @override
  String get captureModeInterval => 'Intervalo';

  @override
  String get btnSaveFrame => 'Guardar Este Fotograma';

  @override
  String get btnSaveMarked => 'Guardar Todos los Fotogramas Marcados';

  @override
  String get btnStartExtraction => 'Iniciar Extracción';

  @override
  String get intervalCustom => 'Personalizar';

  @override
  String intervalSeconds(String seconds) {
    return '${seconds}s';
  }

  @override
  String frameEstimate(int count) {
    return '±$count fotogramas';
  }

  @override
  String frameIndicator(int current, int total) {
    return 'Fotograma $current / $total';
  }

  @override
  String get errorFailedExtract => 'Error al extraer el fotograma';

  @override
  String get titleCapture => 'Extracción';

  @override
  String progressFrames(int current, int total) {
    return '$current / $total fotogramas';
  }

  @override
  String progressRemaining(String time) {
    return 'Restante $time';
  }

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnOpenGallery => 'Abrir Galería';

  @override
  String get btnClose => 'Cerrar';

  @override
  String extractionComplete(int count) {
    return '$count fotogramas guardados en Pictures/Sela';
  }

  @override
  String extractionCancelled(int count) {
    return 'Extracción cancelada. $count fotogramas guardados.';
  }

  @override
  String errorMaxFramesExceeded(int max) {
    return 'Límite máximo de $max fotogramas superado. Reduce la duración o aumenta el intervalo.';
  }

  @override
  String get singleFrameSaved => 'Fotograma guardado en Pictures/Sela';

  @override
  String get errorSaveFrame => 'Error al guardar el fotograma';

  @override
  String get titleExtracting => 'Extrayendo fotogramas...';

  @override
  String get titleHistory => 'Historial';

  @override
  String get emptyHistory => 'Aún no hay historial de extracción';

  @override
  String get dialogResumeTitle => '¿Reanudar Extracción?';

  @override
  String dialogResumeMessage(int nextFrame) {
    return '¿Continuar desde el fotograma $nextFrame?';
  }

  @override
  String get btnResume => 'Reanudar';

  @override
  String get btnRestart => 'Reiniciar';

  @override
  String get sessionDeleted => 'Historial eliminado';

  @override
  String historyTotalFrames(int count) {
    return '$count fotogramas';
  }

  @override
  String historyFileSize(String sizeMb) {
    return '±$sizeMb MB';
  }

  @override
  String get titleSettings => 'Ajustes';

  @override
  String get sectionExtraction => 'Extracción';

  @override
  String get labelFormat => 'Formato de Archivo';

  @override
  String get labelJpegQuality => 'Calidad JPEG';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get titleSelectLanguage => 'Seleccionar Idioma';

  @override
  String get searchLanguage => 'Buscar idioma...';

  @override
  String get sectionSuggested => 'Sugerido';

  @override
  String get sectionAllLanguages => 'Todos los Idiomas';

  @override
  String get languageChanged => 'Idioma cambiado';

  @override
  String get btnUndo => 'Deshacer';

  @override
  String get dialogRtlTitle => '¿Cambiar Diseño (RTL)?';

  @override
  String dialogRtlMessage(String language) {
    return 'Cambiar a $language invertirá todo el diseño de la interfaz. ¿Deseas continuar?';
  }

  @override
  String get btnApply => 'Aplicar';

  @override
  String get sectionAbout => 'Acerca de';

  @override
  String get titleHome => 'Inicio';

  @override
  String get btnPickVideo => 'Elegir Video';

  @override
  String get homeHeadline => 'Captura momentos\nde tus videos.';

  @override
  String get homeSubtitle => 'Extrae fotogramas fijos con precisión.';

  @override
  String get homePickVideo => 'Seleccionar video';

  @override
  String get homeSupportedFormats => 'MP4 · MOV · MKV · WEBM';

  @override
  String get homePickFolder => 'Seleccionar carpeta';

  @override
  String get tabExtract => 'Extraer';

  @override
  String get titleResults => 'Resultados';

  @override
  String get btnSelectAll => 'Seleccionar todo';

  @override
  String get btnDeselectAll => 'Deseleccionar todo';

  @override
  String get btnSaveToGallery => 'Guardar en Galería';

  @override
  String get btnShare => 'Compartir';

  @override
  String get btnViewResults => 'Ver Resultados';

  @override
  String resultsSelectedCount(int count, String sizeMb) {
    return '$count fotogramas · $sizeMb MB';
  }

  @override
  String get folderPickNotice =>
      'La selección de carpeta estará disponible en una próxima actualización';

  @override
  String get titleDeleteSession => 'Eliminar Historial';

  @override
  String get confirmDeleteSession =>
      '¿Estás seguro de que deseas eliminar este elemento del historial?';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get customIntervalTitle => 'Definir Intervalo';

  @override
  String get customIntervalHint => 'Segundos (ej. 0.1 o 3)';

  @override
  String titlePhotos(int count) {
    return 'Fotos ($count)';
  }

  @override
  String get resultsSubtitle => 'Toca para seleccionar fotos';

  @override
  String get btnSaveAll => 'Guardar Todo';

  @override
  String get btnSaveSelected => 'Guardar Seleccionadas';

  @override
  String savedToFolder(int count, String folder) {
    return '$count fotogramas guardados en $folder';
  }

  @override
  String get errorSharePhotos => 'Error al compartir fotos';

  @override
  String get sectionStorage => 'Almacenamiento y Carpeta';

  @override
  String get labelOrganizeByVideo => 'Organizar por Video';

  @override
  String get subOrganizeByVideo =>
      'Crea automáticamente una subcarpeta con el nombre del video para mantener organizados los fotogramas.';

  @override
  String get labelPickFolder => 'Seleccionar Carpeta de Destino';

  @override
  String get tooltipResetDefault => 'Restablecer a Predeterminado';

  @override
  String storageFolderChanged(String path) {
    return 'Carpeta de almacenamiento cambiada a $path';
  }

  @override
  String titleSelectVideoCount(int count) {
    return 'Seleccionar Video ($count)';
  }
}
