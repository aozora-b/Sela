import 'package:flutter_test/flutter_test.dart';

import 'package:sela/domain/language_models.dart';
import 'package:sela/domain/models.dart';
import 'package:sela/domain/session_models.dart';
import 'package:sela/domain/settings_models.dart';

VideoInfo _info(double duration) => VideoInfo(
  path: 'video.mp4',
  durationS: duration,
  fps: 30,
  width: 1920,
  height: 1080,
  frameCount: (duration * 30).toInt(),
  codec: 'h264',
);

void main() {
  group('model pengaturan & sesi', () {
    test('AppSettings default: png/90/dark/id', () {
      const s = AppSettings();
      expect(s.format, OutputFormat.png);
      expect(s.jpegQuality, 90);
      expect(s.themeMode, AppThemeMode.dark);
      expect(s.localeCode, 'id');
    });

    test('pemetaan RTL tepat untuk ar/fa/he/ur', () {
      for (final code in ['ar', 'fa', 'he', 'ur']) {
        expect(AppLanguage.isLanguageRtl(code), isTrue, reason: code);
      }
      expect(AppLanguage.isLanguageRtl('id'), isFalse);
      expect(AppLanguage.isLanguageRtl('en'), isFalse);
    });

    test('canResume hanya benar saat 0 < savedCount < total', () {
      ExtractionSession s(int saved, int total) => ExtractionSession(
        id: 'x',
        videoPath: 'v.mp4',
        savedCount: saved,
        lastIndex: saved,
        total: total,
        timestamp: DateTime(2026),
      );
      expect(s(0, 10).canResume, isFalse);
      expect(s(5, 10).canResume, isTrue);
      expect(s(10, 10).canResume, isFalse);
    });

    test('resolusi VideoInfo memakai tanda kali (×)', () {
      expect(_info(10).resolution, '1920×1080');
    });
  });
}
