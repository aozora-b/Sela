import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Sela'**
  String get appName;

  /// No description provided for @captureModeManual.
  ///
  /// In id, this message translates to:
  /// **'Manual'**
  String get captureModeManual;

  /// No description provided for @captureModeInterval.
  ///
  /// In id, this message translates to:
  /// **'Interval'**
  String get captureModeInterval;

  /// No description provided for @btnSaveFrame.
  ///
  /// In id, this message translates to:
  /// **'Simpan Frame Ini'**
  String get btnSaveFrame;

  /// No description provided for @btnSaveMarked.
  ///
  /// In id, this message translates to:
  /// **'Simpan Semua Frame Ditandai'**
  String get btnSaveMarked;

  /// No description provided for @btnStartExtraction.
  ///
  /// In id, this message translates to:
  /// **'Mulai Ekstraksi'**
  String get btnStartExtraction;

  /// No description provided for @intervalCustom.
  ///
  /// In id, this message translates to:
  /// **'Atur'**
  String get intervalCustom;

  /// No description provided for @intervalSeconds.
  ///
  /// In id, this message translates to:
  /// **'{seconds} dtk'**
  String intervalSeconds(String seconds);

  /// No description provided for @frameEstimate.
  ///
  /// In id, this message translates to:
  /// **'±{count} frame · ±{sizeMb} MB'**
  String frameEstimate(int count, String sizeMb);

  /// No description provided for @frameIndicator.
  ///
  /// In id, this message translates to:
  /// **'Frame {current} / {total}'**
  String frameIndicator(int current, int total);

  /// No description provided for @errorFailedExtract.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengambil frame'**
  String get errorFailedExtract;

  /// No description provided for @titleCapture.
  ///
  /// In id, this message translates to:
  /// **'Ekstraksi'**
  String get titleCapture;

  /// No description provided for @progressFrames.
  ///
  /// In id, this message translates to:
  /// **'{current} / {total} frame'**
  String progressFrames(int current, int total);

  /// No description provided for @progressRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa {time}'**
  String progressRemaining(String time);

  /// No description provided for @btnCancel.
  ///
  /// In id, this message translates to:
  /// **'Batalkan'**
  String get btnCancel;

  /// No description provided for @btnOpenGallery.
  ///
  /// In id, this message translates to:
  /// **'Buka Galeri'**
  String get btnOpenGallery;

  /// No description provided for @btnClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get btnClose;

  /// No description provided for @extractionComplete.
  ///
  /// In id, this message translates to:
  /// **'{count} frame tersimpan di Pictures/Sela'**
  String extractionComplete(int count);

  /// No description provided for @extractionCancelled.
  ///
  /// In id, this message translates to:
  /// **'Ekstraksi dibatalkan. {count} frame tersimpan.'**
  String extractionCancelled(int count);

  /// No description provided for @errorMaxFramesExceeded.
  ///
  /// In id, this message translates to:
  /// **'Batas maksimum {max} frame terlampaui. Kurangi durasi atau perbesar interval.'**
  String errorMaxFramesExceeded(int max);

  /// No description provided for @singleFrameSaved.
  ///
  /// In id, this message translates to:
  /// **'Frame tersimpan di Pictures/Sela'**
  String get singleFrameSaved;

  /// No description provided for @errorSaveFrame.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan frame'**
  String get errorSaveFrame;

  /// No description provided for @titleExtracting.
  ///
  /// In id, this message translates to:
  /// **'Mengekstrak frame...'**
  String get titleExtracting;

  /// No description provided for @titleHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get titleHistory;

  /// No description provided for @emptyHistory.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat ekstraksi'**
  String get emptyHistory;

  /// No description provided for @dialogResumeTitle.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan Ekstraksi?'**
  String get dialogResumeTitle;

  /// No description provided for @dialogResumeMessage.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan dari frame {nextFrame}?'**
  String dialogResumeMessage(int nextFrame);

  /// No description provided for @btnResume.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get btnResume;

  /// No description provided for @btnRestart.
  ///
  /// In id, this message translates to:
  /// **'Mulai Ulang'**
  String get btnRestart;

  /// No description provided for @sessionDeleted.
  ///
  /// In id, this message translates to:
  /// **'Riwayat dihapus'**
  String get sessionDeleted;

  /// No description provided for @historyTotalFrames.
  ///
  /// In id, this message translates to:
  /// **'{count} frame'**
  String historyTotalFrames(int count);

  /// No description provided for @historyFileSize.
  ///
  /// In id, this message translates to:
  /// **'±{sizeMb} MB'**
  String historyFileSize(String sizeMb);

  /// No description provided for @titleSettings.
  ///
  /// In id, this message translates to:
  /// **'Setelan'**
  String get titleSettings;

  /// No description provided for @sectionExtraction.
  ///
  /// In id, this message translates to:
  /// **'Ekstraksi'**
  String get sectionExtraction;

  /// No description provided for @labelFormat.
  ///
  /// In id, this message translates to:
  /// **'Format Berkas'**
  String get labelFormat;

  /// No description provided for @labelJpegQuality.
  ///
  /// In id, this message translates to:
  /// **'Kualitas JPEG'**
  String get labelJpegQuality;

  /// No description provided for @sectionAppearance.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get sectionAppearance;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @sectionLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get sectionLanguage;

  /// No description provided for @titleSelectLanguage.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get titleSelectLanguage;

  /// No description provided for @searchLanguage.
  ///
  /// In id, this message translates to:
  /// **'Cari bahasa...'**
  String get searchLanguage;

  /// No description provided for @sectionSuggested.
  ///
  /// In id, this message translates to:
  /// **'Disarankan'**
  String get sectionSuggested;

  /// No description provided for @sectionAllLanguages.
  ///
  /// In id, this message translates to:
  /// **'Semua Bahasa'**
  String get sectionAllLanguages;

  /// No description provided for @languageChanged.
  ///
  /// In id, this message translates to:
  /// **'Bahasa diubah'**
  String get languageChanged;

  /// No description provided for @btnUndo.
  ///
  /// In id, this message translates to:
  /// **'Urungkan'**
  String get btnUndo;

  /// No description provided for @dialogRtlTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Tata Letak (RTL)?'**
  String get dialogRtlTitle;

  /// No description provided for @dialogRtlMessage.
  ///
  /// In id, this message translates to:
  /// **'Mengubah ke {language} akan mencerminkan seluruh tata letak antarmuka. Lanjutkan?'**
  String dialogRtlMessage(String language);

  /// No description provided for @btnApply.
  ///
  /// In id, this message translates to:
  /// **'Terapkan'**
  String get btnApply;

  /// No description provided for @sectionAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get sectionAbout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
