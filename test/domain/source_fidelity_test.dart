import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/models.dart';

void main() {
  group('Source Resolution Fidelity Verification (Tahap 7)', () {
    test('VideoInfo resolution getter produces exact width and height', () {
      const info = VideoInfo(
        path: 'assets/test.mp4',
        durationS: 10.0,
        fps: 30.0,
        frameCount: 300,
        width: 320,
        height: 176,
        codec: 'h264',
      );

      expect(info.width, 320);
      expect(info.height, 176);
      expect(info.resolution, '320×176');
    });

    test(
      'assets/test.mp4 binary MP4 container defines native 320x176 track',
      () {
        final file = File('assets/test.mp4');
        expect(file.existsSync(), isTrue);

        final bytes = file.readAsBytesSync();
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

        // Assert that 320x176 is the authentic 100% full source resolution of test.mp4
        expect(foundWidth, 320);
        expect(foundHeight, 176);
      },
    );
  });
}
