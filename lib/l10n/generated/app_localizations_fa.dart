// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appName => 'سلا';

  @override
  String get captureModeManual => 'دستی';

  @override
  String get captureModeInterval => 'فاصله‌ای';

  @override
  String get btnSaveFrame => 'ذخیره این فریم';

  @override
  String get btnSaveMarked => 'ذخیره همه فریم‌های نشان‌گذاری‌شده';

  @override
  String get btnStartExtraction => 'شروع استخراج';

  @override
  String get intervalCustom => 'سفارشی';

  @override
  String intervalSeconds(String seconds) {
    return '$seconds ثانیه';
  }

  @override
  String frameEstimate(int count) {
    return 'تقریباً $count فریم';
  }

  @override
  String frameIndicator(int current, int total) {
    return 'فریم $current از $total';
  }

  @override
  String get errorFailedExtract => 'خطا در استخراج فریم';

  @override
  String get titleCapture => 'استخراج';

  @override
  String progressFrames(int current, int total) {
    return '$current از $total فریم';
  }

  @override
  String progressRemaining(String time) {
    return 'باقی‌مانده $time';
  }

  @override
  String get btnCancel => 'لغو';

  @override
  String get btnOpenGallery => 'باز کردن گالری';

  @override
  String get btnClose => 'بستن';

  @override
  String extractionComplete(int count) {
    return '$count فریم در Pictures/Sela ذخیره شد';
  }

  @override
  String extractionCancelled(int count) {
    return 'استخراج لغو شد. $count فریم ذخیره گردید.';
  }

  @override
  String errorMaxFramesExceeded(int max) {
    return 'حداکثر مجاز $max فریم فراتر رفته است. مدت را کاهش یا فاصله را افزایش دهید.';
  }

  @override
  String get singleFrameSaved => 'فریم در Pictures/Sela ذخیره شد';

  @override
  String get errorSaveFrame => 'خطا در ذخیره فریم';

  @override
  String get titleExtracting => 'در حال استخراج فریم‌ها...';

  @override
  String get titleHistory => 'تاریخچه';

  @override
  String get emptyHistory => 'هنوز تاریخچه استخراجی وجود ندارد';

  @override
  String get dialogResumeTitle => 'ادامه استخراج؟';

  @override
  String dialogResumeMessage(int nextFrame) {
    return 'از فریم $nextFrame ادامه داده شود؟';
  }

  @override
  String get btnResume => 'ادامه';

  @override
  String get btnRestart => 'شروع مجدد';

  @override
  String get sessionDeleted => 'تاریخچه حذف شد';

  @override
  String historyTotalFrames(int count) {
    return '$count فریم';
  }

  @override
  String historyFileSize(String sizeMb) {
    return 'تقریباً $sizeMb مگابایت';
  }

  @override
  String get titleSettings => 'تنظیمات';

  @override
  String get sectionExtraction => 'استخراج';

  @override
  String get labelFormat => 'فرمت فایل';

  @override
  String get labelJpegQuality => 'کیفیت JPEG';

  @override
  String get sectionAppearance => 'ظاهر';

  @override
  String get themeDark => 'تاریک';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeSystem => 'سیستم';

  @override
  String get sectionLanguage => 'زبان';

  @override
  String get titleSelectLanguage => 'انتخاب زبان';

  @override
  String get searchLanguage => 'جستجوی زبان...';

  @override
  String get sectionSuggested => 'پیشنهادی';

  @override
  String get sectionAllLanguages => 'همه زبان‌ها';

  @override
  String get languageChanged => 'زبان تغییر کرد';

  @override
  String get btnUndo => 'بازگردانی';

  @override
  String get dialogRtlTitle => 'تغییر چیدمان (RTL)؟';

  @override
  String dialogRtlMessage(String language) {
    return 'تغییر به $language کل چیدمان رابط را معکوس می‌کند. ادامه می‌دهید؟';
  }

  @override
  String get btnApply => 'اعمال';

  @override
  String get sectionAbout => 'درباره';

  @override
  String get titleHome => 'خانه';

  @override
  String get btnPickVideo => 'انتخاب ویدیو';

  @override
  String get homeHeadline => 'ثبت لحظات\nاز ویدیوها.';

  @override
  String get homeSubtitle => 'استخراج دقیق فریم‌های ثابت با وضوح بالا.';

  @override
  String get homePickVideo => 'انتخاب ویدیو';

  @override
  String get homeSupportedFormats => 'MP4 · MOV · MKV · WEBM';

  @override
  String get homePickFolder => 'انتخاب پوشه';

  @override
  String get tabExtract => 'استخراج';

  @override
  String get titleResults => 'نتایج';

  @override
  String get btnSelectAll => 'انتخاب همه';

  @override
  String get btnDeselectAll => 'لغو انتخاب';

  @override
  String get btnSaveToGallery => 'ذخیره در گالری';

  @override
  String get btnShare => 'اشتراک‌گذاری';

  @override
  String get btnViewResults => 'مشاهده نتایج';

  @override
  String resultsSelectedCount(int count, String sizeMb) {
    return '$count فریم · $sizeMb مگابایت';
  }

  @override
  String get folderPickNotice =>
      'انتخاب پوشه در به‌روزرسانی بعدی در دسترس خواهد بود';

  @override
  String get titleDeleteSession => 'حذف تاریخچه';

  @override
  String get confirmDeleteSession =>
      'آیا از حذف این مورد از تاریخچه اطمینان دارید؟';

  @override
  String get btnDelete => 'حذف';

  @override
  String get customIntervalTitle => 'تنظیم فاصله';

  @override
  String get customIntervalHint => 'ثانیه (مثال: 0.1 یا 3)';

  @override
  String titlePhotos(int count) {
    return 'عکس‌ها ($count)';
  }

  @override
  String get resultsSubtitle => 'برای انتخاب عکس ضربه بزنید';

  @override
  String get btnSaveAll => 'ذخیره همه';

  @override
  String get btnSaveSelected => 'ذخیره موارد انتخابی';

  @override
  String savedToFolder(int count, String folder) {
    return '$count فریم در $folder ذخیره شد';
  }

  @override
  String get errorSharePhotos => 'خطا در اشتراک‌گذاری عکس‌ها';

  @override
  String get sectionStorage => 'فضای ذخیره‌سازی و پوشه';

  @override
  String get labelOrganizeByVideo => 'دسته‌بندی بر اساس ویدیو';

  @override
  String get subOrganizeByVideo =>
      'پوشه فرعی با نام ویدیو برای مرتب نگه داشتن فریم‌ها ایجاد می‌شود.';

  @override
  String get labelPickFolder => 'انتخاب پوشه ذخیره‌سازی';

  @override
  String get tooltipResetDefault => 'بازگردانی به پیش‌فرض';

  @override
  String storageFolderChanged(String path) {
    return 'پوشه ذخیره‌سازی به $path تغییر یافت';
  }

  @override
  String titleSelectVideoCount(int count) {
    return 'انتخاب ویدیو ($count)';
  }
}
