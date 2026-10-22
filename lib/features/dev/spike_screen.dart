import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../engine/frame_engine_channel.dart';

class SpikeScreen extends StatefulWidget {
  const SpikeScreen({super.key});

  @override
  State<SpikeScreen> createState() => _SpikeScreenState();
}

class _SpikeScreenState extends State<SpikeScreen> {
  final engine = FrameEngineChannel();
  Uint8List? frameBytes;
  String status = "Siap";

  Future<void> _extractFrame() async {
    setState(() => status = "Menyalin aset...");
    try {
      final byteData = await rootBundle.load('assets/test.mp4');
      final bytes = byteData.buffer.asUint8List();
      final tempFile = File('${Directory.systemTemp.path}/test.mp4');
      await tempFile.writeAsBytes(bytes);

      setState(() => status = "Membuka engine...");
      await engine.open(tempFile.path);

      setState(() => status = "Mengekstrak frame...");
      final resultBytes = await engine.getFrame(3.0, exact: true);

      setState(() {
        frameBytes = Uint8List.fromList(resultBytes);
        status = "Berhasil: ${frameBytes!.length} bytes";
      });
    } catch (e) {
      setState(() => status = "Gagal: $e");
    } finally {
      await engine.close();
    }
  }

  @override
  void dispose() {
    engine.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spike Engine')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status),
            const SizedBox(height: 20),
            if (frameBytes != null)
              Image.memory(frameBytes!, height: 300)
            else
              const SizedBox(height: 300, child: Placeholder()),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _extractFrame,
              child: const Text('Ambil frame di detik 3'),
            ),
          ],
        ),
      ),
    );
  }
}
