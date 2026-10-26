import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sela/engine/frame_engine_channel.dart';
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('resolusi frame hasil ektraksi sama dengan sumber', (
    tester,
  ) async {
    final cases = <(String, int, int)>[
      ('assets/test.mp4', 320, 176),
      ('assets/test_1080p.mp4', 1920, 1080),
    ];

    for (final (asset, srcW, srcH) in cases) {
      final data = await rootBundle.load(asset);
      final dir = Directory.systemTemp.createTempSync('sela_it_');
      final file = File('${dir.path}/input.mp4');
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);

      final engine = FrameEngineChannel();
      try {
        // Metadata Source
        final info = await engine.open(file.path);
        expect(info.width, srcW, reason: 'lebar metadata $asset');
        expect(info.height, srcH, reason: 'tinggi metadata $asset');

        // no scale
        final bytes = await engine.getFrame(0.0, exact: true, format: 'jpeg');
        expect(bytes, isNotEmpty, reason: 'frame $asset tidak kosong');

        final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
        final frame = await codec.getNextFrame();
        expect(frame.image.width, srcW, reason: 'lebar frame $asset');
        expect(frame.image.height, srcH, reason: 'tinggi frame $asset');
        frame.image.dispose();
      } finally {
        await engine.close();
        dir.deleteSync(recursive: true);
      }
    }
  });
}
