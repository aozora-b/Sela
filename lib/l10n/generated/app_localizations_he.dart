// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appName => 'סלה';

  @override
  String get captureModeManual => 'ידני';

  @override
  String get captureModeInterval => 'מרווחים';

  @override
  String get btnSaveFrame => 'שמור פריים זה';

  @override
  String get btnSaveMarked => 'שמור את כל הפריימים המסומנים';

  @override
  String get btnStartExtraction => 'התחל חילוץ';

  @override
  String get intervalCustom => 'מותאם אישית';

  @override
  String intervalSeconds(String seconds) {
    return '$seconds שנ׳';
  }

  @override
  String frameEstimate(int count) {
    return 'כ-$count פריימים';
  }

  @override
  String frameIndicator(int current, int total) {
    return 'פריים $current / $total';
  }

  @override
  String get errorFailedExtract => 'שגיאה בחילוץ הפריים';

  @override
  String get titleCapture => 'חילוץ';

  @override
  String progressFrames(int current, int total) {
    return '$current / $total פריימים';
  }

  @override
  String progressRemaining(String time) {
    return 'נותרו $time';
  }

  @override
  String get btnCancel => 'ביטול';

  @override
  String get btnOpenGallery => 'פתח גלריה';

  @override
  String get btnClose => 'סגור';

  @override
  String extractionComplete(int count) {
    return '$count פריימים נשמרו ב-Pictures/Sela';
  }

  @override
  String extractionCancelled(int count) {
    return 'החילוץ בוטל. $count פריימים נשמרו.';
  }

  @override
  String errorMaxFramesExceeded(int max) {
    return 'חרגת מהמגבלה של $max פריימים. קצר את משך הזמן או הגדל את המרווח.';
  }

  @override
  String get singleFrameSaved => 'הפריים נשמר ב-Pictures/Sela';

  @override
  String get errorSaveFrame => 'שגיאה בשמירת הפריים';

  @override
  String get titleExtracting => 'מחלץ פריימים...';

  @override
  String get titleHistory => 'היסטוריה';

  @override
  String get emptyHistory => 'אין עדיין היסטוריית חילוץ';

  @override
  String get dialogResumeTitle => 'להמשיך בחילוץ?';

  @override
  String dialogResumeMessage(int nextFrame) {
    return 'להמשיך מפריים $nextFrame?';
  }

  @override
  String get btnResume => 'המשך';

  @override
  String get btnRestart => 'התחל מחדש';

  @override
  String get sessionDeleted => 'ההיסטוריה נמחקה';

  @override
  String historyTotalFrames(int count) {
    return '$count פריימים';
  }

  @override
  String historyFileSize(String sizeMb) {
    return 'כ-$sizeMb מ״ב';
  }

  @override
  String get titleSettings => 'הגדרות';

  @override
  String get sectionExtraction => 'חילוץ';

  @override
  String get labelFormat => 'פורמט קובץ';

  @override
  String get labelJpegQuality => 'איכות JPEG';

  @override
  String get sectionAppearance => 'מראה';

  @override
  String get themeDark => 'כהה';

  @override
  String get themeLight => 'בהיר';

  @override
  String get themeSystem => 'מערכת';

  @override
  String get sectionLanguage => 'שפה';

  @override
  String get titleSelectLanguage => 'בחר שפה';

  @override
  String get searchLanguage => 'חיפוש שפה...';

  @override
  String get sectionSuggested => 'מומלץ';

  @override
  String get sectionAllLanguages => 'כל השפות';

  @override
  String get languageChanged => 'השפה שונתה';

  @override
  String get btnUndo => 'בטל';

  @override
  String get dialogRtlTitle => 'לשנות כיוון תצוגה (RTL)?';

  @override
  String dialogRtlMessage(String language) {
    return 'מעבר לשפה $language יהפוך את כל פריסת הממשק. להמשיך?';
  }

  @override
  String get btnApply => 'החל';

  @override
  String get sectionAbout => 'אודות';

  @override
  String get titleHome => 'בית';

  @override
  String get btnPickVideo => 'בחר סרטון';

  @override
  String get homeHeadline => 'ללכוד רגעים\nמסרטונים.';

  @override
  String get homeSubtitle => 'חילוץ תמונות סטילס בדיוק מרבי.';

  @override
  String get homePickVideo => 'בחר סרטון';

  @override
  String get homeSupportedFormats => 'MP4 · MOV · MKV · WEBM';

  @override
  String get homePickFolder => 'בחר תיקייה';

  @override
  String get tabExtract => 'חילוץ';

  @override
  String get titleResults => 'תוצאות';

  @override
  String get btnSelectAll => 'בחר הכל';

  @override
  String get btnDeselectAll => 'בטל בחירה';

  @override
  String get btnSaveToGallery => 'שמור לגלריה';

  @override
  String get btnShare => 'שתף';

  @override
  String get btnViewResults => 'צפה בתוצאות';

  @override
  String resultsSelectedCount(int count, String sizeMb) {
    return '$count פריימים · $sizeMb מ״ב';
  }

  @override
  String get folderPickNotice => 'בחירת תיקייה תהיה זמינה בעדכון קרוב';

  @override
  String get titleDeleteSession => 'מחיקת היסטוריה';

  @override
  String get confirmDeleteSession =>
      'האם אתה בטוח שברצונך למחוק פריט היסטוריה זה?';

  @override
  String get btnDelete => 'מחק';

  @override
  String get customIntervalTitle => 'הגדרת מרווח';

  @override
  String get customIntervalHint => 'שניות (למשל: 0.1 או 3)';

  @override
  String titlePhotos(int count) {
    return 'תמונות ($count)';
  }

  @override
  String get resultsSubtitle => 'הקש כדי לבחור תמונות';

  @override
  String get btnSaveAll => 'שמור הכל';

  @override
  String get btnSaveSelected => 'שמור נבחרים';

  @override
  String savedToFolder(int count, String folder) {
    return '$count פריימים נשמרו ב-$folder';
  }

  @override
  String get errorSharePhotos => 'שגיאה בשיתוף תמונות';

  @override
  String get sectionStorage => 'אחסון ותיקייה';

  @override
  String get labelOrganizeByVideo => 'ארגון לפי סרטון';

  @override
  String get subOrganizeByVideo =>
      'יוצר אוטומטית תת-תיקייה לפי שם הסרטון כדי לשמור על סדר הפריימים.';

  @override
  String get labelPickFolder => 'בחר תיקיית יעד';

  @override
  String get tooltipResetDefault => 'איפוס לברירת מחדל';

  @override
  String storageFolderChanged(String path) {
    return 'תיקיית האחסון שונתה ל-$path';
  }

  @override
  String titleSelectVideoCount(int count) {
    return 'בחר סרטון ($count)';
  }
}
