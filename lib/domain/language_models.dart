class AppLanguage {
  final String code;
  final String nativeName;
  final String englishName;
  final bool isRtl;

  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
    this.isRtl = false,
  });

  static const List<AppLanguage> suggested = [
    AppLanguage(
      code: 'id',
      nativeName: 'Bahasa Indonesia',
      englishName: 'Indonesian',
    ),
    AppLanguage(code: 'en', nativeName: 'English', englishName: 'English'),
  ];

  static const List<AppLanguage> all = [
    AppLanguage(
      code: 'id',
      nativeName: 'Bahasa Indonesia',
      englishName: 'Indonesian',
    ),
    AppLanguage(code: 'en', nativeName: 'English', englishName: 'English'),
    AppLanguage(
      code: 'ar',
      nativeName: 'العربية',
      englishName: 'Arabic',
      isRtl: true,
    ),
    AppLanguage(
      code: 'fa',
      nativeName: 'فارسی',
      englishName: 'Persian',
      isRtl: true,
    ),
    AppLanguage(
      code: 'he',
      nativeName: 'עברית',
      englishName: 'Hebrew',
      isRtl: true,
    ),
    AppLanguage(
      code: 'ur',
      nativeName: 'اردو',
      englishName: 'Urdu',
      isRtl: true,
    ),
    AppLanguage(code: 'es', nativeName: 'Español', englishName: 'Spanish'),
    AppLanguage(code: 'fr', nativeName: 'Français', englishName: 'French'),
    AppLanguage(code: 'de', nativeName: 'Deutsch', englishName: 'German'),
    AppLanguage(code: 'ja', nativeName: '日本語', englishName: 'Japanese'),
  ];

  static bool isLanguageRtl(String code) {
    for (final lang in all) {
      if (lang.code == code) return lang.isRtl;
    }
    return false;
  }
}
