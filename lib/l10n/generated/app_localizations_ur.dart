// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'سیلا';

  @override
  String get captureModeManual => 'دستی';

  @override
  String get captureModeInterval => 'وقفہ';

  @override
  String get btnSaveFrame => 'یہ فریم محفوظ کریں';

  @override
  String get btnSaveMarked => 'تمام نشان زدہ فریم محفوظ کریں';

  @override
  String get btnStartExtraction => 'استخراج شروع کریں';

  @override
  String get intervalCustom => 'اپنی مرضی کا';

  @override
  String intervalSeconds(String seconds) {
    return '$seconds سیکنڈ';
  }

  @override
  String frameEstimate(int count) {
    return 'تقریباً $count فریم';
  }

  @override
  String frameIndicator(int current, int total) {
    return 'فریم $current / $total';
  }

  @override
  String get errorFailedExtract => 'فریم حاصل کرنے میں ناکامی';

  @override
  String get titleCapture => 'استخراج';

  @override
  String progressFrames(int current, int total) {
    return '$current / $total فریم';
  }

  @override
  String progressRemaining(String time) {
    return 'باقی وقت $time';
  }

  @override
  String get btnCancel => 'منسوخ کریں';

  @override
  String get btnOpenGallery => 'گیلری کھولیں';

  @override
  String get btnClose => 'بند کریں';

  @override
  String extractionComplete(int count) {
    return 'Pictures/Sela میں $count فریم محفوظ ہو گئے';
  }

  @override
  String extractionCancelled(int count) {
    return 'استخراج منسوخ کر دیا گیا۔ $count فریم محفوظ ہوئے۔';
  }

  @override
  String errorMaxFramesExceeded(int max) {
    return 'زیادہ سے زیادہ $max فریم کی حد تجاوز کر گئی ہے۔ دورانیہ کم کریں یا وقفہ بڑھائیں۔';
  }

  @override
  String get singleFrameSaved => 'فریم Pictures/Sela میں محفوظ ہو گیا';

  @override
  String get errorSaveFrame => 'فریم محفوظ کرنے میں ناکامی';

  @override
  String get titleExtracting => 'فریم نکالے جا رہے ہیں...';

  @override
  String get titleHistory => 'تاریخچہ';

  @override
  String get emptyHistory => 'ابھی تک کوئی تاریخچہ نہیں ہے';

  @override
  String get dialogResumeTitle => 'کیا استخراج جاری رکھیں؟';

  @override
  String dialogResumeMessage(int nextFrame) {
    return 'فریم $nextFrame سے جاری رکھیں؟';
  }

  @override
  String get btnResume => 'جاری رکھیں';

  @override
  String get btnRestart => 'دوبارہ شروع کریں';

  @override
  String get sessionDeleted => 'تاریخچہ حذف ہو گیا';

  @override
  String historyTotalFrames(int count) {
    return '$count فریم';
  }

  @override
  String historyFileSize(String sizeMb) {
    return 'تقریباً $sizeMb ایم بی';
  }

  @override
  String get titleSettings => 'ترتیبات';

  @override
  String get sectionExtraction => 'استخراج';

  @override
  String get labelFormat => 'فائل فارمیٹ';

  @override
  String get labelJpegQuality => 'جے پی ای جی کوالٹی';

  @override
  String get sectionAppearance => 'ظاہری شکل';

  @override
  String get themeDark => 'ڈارک';

  @override
  String get themeLight => 'لائٹ';

  @override
  String get themeSystem => 'سسٹم';

  @override
  String get sectionLanguage => 'زبان';

  @override
  String get titleSelectLanguage => 'زبان منتخب کریں';

  @override
  String get searchLanguage => 'زبان تلاش کریں...';

  @override
  String get sectionSuggested => 'تجویز کردہ';

  @override
  String get sectionAllLanguages => 'تمام زبانیں';

  @override
  String get languageChanged => 'زبان تبدیل ہو گئی';

  @override
  String get btnUndo => 'کالعدم کریں';

  @override
  String get dialogRtlTitle => 'لے آؤٹ تبدیل کریں (RTL)؟';

  @override
  String dialogRtlMessage(String language) {
    return '$language پر سوئچ کرنے سے پورا انٹرفیس معکوس ہو جائے گا۔ کیا آپ جاری رکھنا چاہتے ہیں؟';
  }

  @override
  String get btnApply => 'لاگو کریں';

  @override
  String get sectionAbout => 'کے بارے میں';

  @override
  String get titleHome => 'ہوم';

  @override
  String get btnPickVideo => 'ویڈیو منتخب کریں';

  @override
  String get homeHeadline => 'ویڈیوز سے\nلمحات محفوظ کریں۔';

  @override
  String get homeSubtitle => 'درست ترین انداز میں اسٹیل فریم نکالیں۔';

  @override
  String get homePickVideo => 'ویڈیو منتخب کریں';

  @override
  String get homeSupportedFormats => 'MP4 · MOV · MKV · WEBM';

  @override
  String get homePickFolder => 'فولڈر منتخب کریں';

  @override
  String get tabExtract => 'استخراج';

  @override
  String get titleResults => 'نتائج';

  @override
  String get btnSelectAll => 'سب منتخب کریں';

  @override
  String get btnDeselectAll => 'انتخاب ختم کریں';

  @override
  String get btnSaveToGallery => 'گیلری میں محفوظ کریں';

  @override
  String get btnShare => 'شیئر کریں';

  @override
  String get btnViewResults => 'نتائج دیکھیں';

  @override
  String resultsSelectedCount(int count, String sizeMb) {
    return '$count فریم · $sizeMb ایم بی';
  }

  @override
  String get folderPickNotice => 'فولڈر کا انتخاب آئندہ اپ ڈیٹ میں دستیاب ہوگا';

  @override
  String get titleDeleteSession => 'تاریخچہ حذف کریں';

  @override
  String get confirmDeleteSession =>
      'کیا آپ واقعی اس تاریخچے کو حذف کرنا چاہتے ہیں؟';

  @override
  String get btnDelete => 'حذف کریں';

  @override
  String get customIntervalTitle => 'وقفہ مقرر کریں';

  @override
  String get customIntervalHint => 'سیکنڈ (مثال: 0.1 یا 3)';

  @override
  String titlePhotos(int count) {
    return 'تصاویر ($count)';
  }

  @override
  String get resultsSubtitle => 'تصاویر منتخب کرنے کے لیے ٹیپ کریں';

  @override
  String get btnSaveAll => 'تمام محفوظ کریں';

  @override
  String get btnSaveSelected => 'منتخب کردہ محفوظ کریں';

  @override
  String savedToFolder(int count, String folder) {
    return '$count فریم $folder میں محفوظ ہو گئے';
  }

  @override
  String get errorSharePhotos => 'تصاویر شیئر کرنے میں ناکامی';

  @override
  String get sectionStorage => 'اسٹوریج اور فولڈر';

  @override
  String get labelOrganizeByVideo => 'ویڈیو کے لحاظ سے منظم کریں';

  @override
  String get subOrganizeByVideo =>
      'فریموں کو منظم رکھنے کے لیے خودکار طور پر ویڈیو کے نام کا ذیلی فولڈر بناتا ہے۔';

  @override
  String get labelPickFolder => 'محفوظ کرنے کا فولڈر منتخب کریں';

  @override
  String get tooltipResetDefault => 'ڈیفالٹ پر بحال کریں';

  @override
  String storageFolderChanged(String path) {
    return 'اسٹوریج کا فولڈر تبدیل ہو کر $path ہو گیا';
  }

  @override
  String titleSelectVideoCount(int count) {
    return 'ویڈیو منتخب کریں ($count)';
  }
}
