// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سيلا';

  @override
  String get captureModeManual => 'يدوي';

  @override
  String get captureModeInterval => 'فواصل زمنية';

  @override
  String get btnSaveFrame => 'حفظ هذا الإطار';

  @override
  String get btnSaveMarked => 'حفظ جميع الإطارات المحددة';

  @override
  String get btnStartExtraction => 'بدء الاستخراج';

  @override
  String get intervalCustom => 'مخصص';

  @override
  String intervalSeconds(String seconds) {
    return '$seconds ث';
  }

  @override
  String frameEstimate(int count, String sizeMb) {
    return '±$count إطار · ±$sizeMb م.ب';
  }

  @override
  String frameIndicator(int current, int total) {
    return 'إطار $current / $total';
  }

  @override
  String get errorFailedExtract => 'فشل استخراج الإطار';

  @override
  String get titleCapture => 'استخراج';

  @override
  String progressFrames(int current, int total) {
    return '$current / $total إطار';
  }

  @override
  String progressRemaining(String time) {
    return 'المتبقي $time';
  }

  @override
  String get btnCancel => 'إلغاء';

  @override
  String get btnOpenGallery => 'فتح المعرض';

  @override
  String get btnClose => 'إغلاق';

  @override
  String extractionComplete(int count) {
    return 'تم حفظ $count إطار في Pictures/Sela';
  }

  @override
  String extractionCancelled(int count) {
    return 'تم إلغاء الاستخراج. تم حفظ $count إطار.';
  }

  @override
  String errorMaxFramesExceeded(int max) {
    return 'تم تجاوز الحد الأقصى $max إطار. قلل المدة أو زد الفاصل الزمني.';
  }

  @override
  String get singleFrameSaved => 'تم حفظ الإطار في Pictures/Sela';

  @override
  String get errorSaveFrame => 'فشل حفظ الإطار';

  @override
  String get titleExtracting => 'جارٍ استخراج الإطارات...';

  @override
  String get titleHistory => 'السجل';

  @override
  String get emptyHistory => 'لا يوجد سجل استخراج حتى الآن';

  @override
  String get dialogResumeTitle => 'استئناف الاستخراج؟';

  @override
  String dialogResumeMessage(int nextFrame) {
    return 'المتابعة من الإطار $nextFrame؟';
  }

  @override
  String get btnResume => 'استئناف';

  @override
  String get btnRestart => 'إعادة البدء';

  @override
  String get sessionDeleted => 'تم حذف السجل';

  @override
  String historyTotalFrames(int count) {
    return '$count إطار';
  }

  @override
  String historyFileSize(String sizeMb) {
    return '±$sizeMb م.ب';
  }

  @override
  String get titleSettings => 'الإعدادات';

  @override
  String get sectionExtraction => 'الاستخراج';

  @override
  String get labelFormat => 'صيغة الملف';

  @override
  String get labelJpegQuality => 'جودة JPEG';

  @override
  String get sectionAppearance => 'المظهر';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeSystem => 'النظام';

  @override
  String get sectionLanguage => 'اللغة';

  @override
  String get titleSelectLanguage => 'اختر اللغة';

  @override
  String get searchLanguage => 'البحث عن لغة...';

  @override
  String get sectionSuggested => 'المقترحة';

  @override
  String get sectionAllLanguages => 'جميع اللغات';

  @override
  String get languageChanged => 'تم تغيير اللغة';

  @override
  String get btnUndo => 'تراجع';

  @override
  String get dialogRtlTitle => 'تغيير التخطيط (RTL)؟';

  @override
  String dialogRtlMessage(String language) {
    return 'التغيير إلى $language سيعكس تخطيط الواجهة بالكامل. هل تريد المتابعة؟';
  }

  @override
  String get btnApply => 'تطبيق';

  @override
  String get sectionAbout => 'حول';
}
