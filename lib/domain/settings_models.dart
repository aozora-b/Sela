import 'formats.dart';

export 'formats.dart' show OutputFormat, OutputFormatX;

enum AppThemeMode { dark, light, system }

class AppSettings {
  final OutputFormat format;
  final int jpegQuality;
  final AppThemeMode themeMode;
  final String localeCode;
  final String customFolder;
  final String? customTreeUri;
  final bool organizeByVideo;

  const AppSettings({
    this.format = OutputFormat.png,
    this.jpegQuality = 90,
    this.themeMode = AppThemeMode.dark,
    this.localeCode = 'id',
    this.customFolder = 'Sela',
    this.customTreeUri,
    this.organizeByVideo = true,
  });

  String resolveSubfolder(String videoStem) {
    final tUri = customTreeUri;
    if (tUri != null && tUri.isNotEmpty) {
      return organizeByVideo ? 'saf|$tUri|$videoStem' : 'saf|$tUri|';
    }
    return organizeByVideo ? '$customFolder/$videoStem' : customFolder;
  }

  AppSettings copyWith({
    OutputFormat? format,
    int? jpegQuality,
    AppThemeMode? themeMode,
    String? localeCode,
    String? customFolder,
    String? customTreeUri,
    bool clearTreeUri = false,
    bool? organizeByVideo,
  }) {
    return AppSettings(
      format: format ?? this.format,
      jpegQuality: jpegQuality ?? this.jpegQuality,
      themeMode: themeMode ?? this.themeMode,
      localeCode: localeCode ?? this.localeCode,
      customFolder: customFolder ?? this.customFolder,
      customTreeUri: clearTreeUri ? null : (customTreeUri ?? this.customTreeUri),
      organizeByVideo: organizeByVideo ?? this.organizeByVideo,
    );
  }
}
