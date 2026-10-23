import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/models.dart';

(int, int) parseNativeTrackDimensions(Uint8List bytes) {
  final byteData = ByteData.sublistView(bytes);
  int pos = 0;
  int foundWidth = 0;
  int foundHeight = 0;

  while (pos < bytes.length - 8) {
    final sz = byteData.getUint32(pos);
    final tag = String.fromCharCodes(bytes.sublist(pos + 4, pos + 8));

    if (tag == 'moov' ||
        tag == 'trak' ||
        tag == 'mdia' ||
        tag == 'minf' ||
        tag == 'stbl') {
      pos += 8;
      continue;
    }

    if (tag == 'tkhd') {
      final version = byteData.getUint8(pos + 8);
      final wIdx = version == 0 ? pos + 8 + 76 : pos + 8 + 88;
      final hIdx = version == 0 ? pos + 8 + 80 : pos + 8 + 92;

      final w = byteData.getUint16(wIdx);
      final h = byteData.getUint16(hIdx);

      if (w > 0 && h > 0 && foundWidth == 0) {
        foundWidth = w;
        foundHeight = h;
      }
    }

    if (sz <= 1) break;
    pos += sz;
  }
  return (foundWidth, foundHeight);
}

void main() {
  group('Source Resolution Fidelity Verification (Tahap 7)', () {
    test('VideoInfo resolution getter produces exact width and height', () {
      const infoLow = VideoInfo(
        path: 'assets/test.mp4',
        durationS: 10.0,
        fps: 30.0,
        frameCount: 300,
        width: 320,
        height: 176,
        codec: 'h264',
      );
      expect(infoLow.resolution, '320×176');

      const infoHigh = VideoInfo(
        path: 'assets/test_1080p.mp4',
        durationS: 2.0,
        fps: 30.0,
        frameCount: 60,
        width: 1920,
        height: 1080,
        codec: 'h264',
      );
      expect(infoHigh.resolution, '1920×1080');
    });

    test('assets/test.mp4 binary MP4 container defines native 320x176', () {
      final file = File('assets/test.mp4');
      expect(file.existsSync(), isTrue);
      final (width, height) = parseNativeTrackDimensions(
        file.readAsBytesSync(),
      );
      expect(width, 320);
      expect(height, 176);
    });

    test(
      'assets/test_1080p.mp4 binary MP4 container defines native 1920x1080',
      () {
        final file = File('assets/test_1080p.mp4');
        expect(file.existsSync(), isTrue);
        final (width, height) = parseNativeTrackDimensions(
          file.readAsBytesSync(),
        );
        expect(width, 1920);
        expect(height, 1080);
      },
    );
  });
}
