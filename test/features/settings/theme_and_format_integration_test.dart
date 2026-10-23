import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/models.dart';
import 'package:sela/theme/sela_theme.dart';

void main() {
  group('SelaTheme Production Verification', () {
    test('lightTheme has Brightness.light and Editorial Light palette', () {
      final theme = SelaTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, SelaColors.bgLight);
      expect(theme.colorScheme.primary, SelaColors.accent);
      expect(theme.colorScheme.surface, SelaColors.surfaceLight);
      expect(theme.colorScheme.onSurface, SelaColors.textPrimaryLight);
    });

    test('darkTheme has Brightness.dark and Editorial Dark palette', () {
      final theme = SelaTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, SelaColors.bg);
      expect(theme.colorScheme.primary, SelaColors.accent);
      expect(theme.colorScheme.surface, SelaColors.surface);
      expect(theme.colorScheme.onSurface, SelaColors.textPrimary);
    });
  });

  group('OutputFormat Unified Production Enum & Extensions', () {
    test('PNG mapping produces png extension and image/png mimeType', () {
      const fmt = OutputFormat.png;
      expect(fmt.ext, 'png');
      expect(fmt.mimeType, 'image/png');
      expect(fmt.label, 'PNG');
    });

    test('JPEG mapping produces jpg extension and image/jpeg mimeType', () {
      const fmt = OutputFormat.jpeg;
      expect(fmt.ext, 'jpg');
      expect(fmt.mimeType, 'image/jpeg');
      expect(fmt.label, 'JPEG');
    });

    test('ExtractOptions accepts OutputFormat.jpeg and custom quality', () {
      final opt = ExtractOptions(
        mode: CaptureMode.interval,
        intervalS: 2.0,
        fmt: OutputFormat.jpeg,
        quality: 85,
      );
      expect(opt.fmt, OutputFormat.jpeg);
      expect(opt.quality, 85);
      expect(opt.fmt.ext, 'jpg');
      expect(opt.fmt.mimeType, 'image/jpeg');
    });
  });
}
