import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/gallery_name_registry.dart';
import '../../domain/exceptions.dart';
import '../../domain/frame_naming.dart';
import '../../domain/models.dart';
import '../../domain/sample_plan.dart';
import '../../engine/frame_engine_channel.dart';
import '../../engine/gallery_writer_channel.dart';
import '../history/history_controller.dart';
import '../history/history_repository.dart';
import '../progress/extraction_progress_controller.dart';
import '../results/results_controller.dart';
import '../settings/settings_controller.dart';

/// Coordinates frame extraction, persistence, and progress state updates.
class ExtractionRunner {
  ExtractionRunner({
    required this.ref,
    required this.engine,
    required this.gallery,
    required this.history,
  });

  final Ref ref;
  final FrameEngineChannel engine;
  final GalleryWriterChannel gallery;
  final HistoryRepository history;

  bool _isCancelled = false;

  void cancel() => _isCancelled = true;

  String _stem(String path) =>
      path.split(Platform.pathSeparator).last.split('.').first;

  Future<void> run({
    required VideoInfo videoInfo,
    required double intervalS,
    required String errorMessage,
    int resumeFromIndex = 0,
  }) async {
    final s = ref.read(settingsProvider);
    final progress = ref.read(extractionProgressProvider.notifier);
    final opt = ExtractOptions(
      mode: CaptureMode.interval,
      intervalS: intervalS,
      fmt: s.format,
      quality: s.jpegQuality,
    );

    final List<double> pts;
    try {
      pts = planPoints(videoInfo, opt);
    } catch (_) {
      return progress.setError(errorMessage);
    }
    if (pts.length > maxFrames) return progress.setError(errorMessage);

    _isCancelled = false;
    final rem = pts.length - resumeFromIndex;
    progress.start(
      pts.length,
      initialCurrent: resumeFromIndex,
      initialRemaining: Duration(milliseconds: rem * 300),
    );

    final reg = GalleryNameRegistry(gallery);
    final stem = _stem(videoInfo.path);
    final sw = Stopwatch()..start();
    int totalBytes = 0;
    final extractedFrames = <FrameResult>[];

    final tempDir = Directory('${Directory.systemTemp.path}/sela_extracted');
    if (!tempDir.existsSync()) {
      tempDir.createSync(recursive: true);
    } else if (resumeFromIndex == 0) {
      try {
        for (final entity in tempDir.listSync()) {
          if (entity is File) entity.deleteSync();
        }
      } catch (_) {}
    }

    try {
      for (int i = resumeFromIndex; i < pts.length; i++) {
        if (_isCancelled) return progress.cancel(i);
        final t = pts[i];
        final bytes = await engine.getFrame(
          t,
          exact: false,
          format: s.format.name,
          quality: s.jpegQuality,
        );
        totalBytes += bytes.length;

        final raw = buildName(
          stem: stem,
          index: i + 1,
          ts: t,
          ext: s.format.ext,
          template: opt.template,
        );
        final name = await uniqueName(reg, raw);

        final cacheFile = File('${tempDir.path}/$name');
        try {
          await cacheFile.writeAsBytes(bytes);
        } catch (_) {}

        extractedFrames.add(
          FrameResult(
            path: cacheFile.path,
            timestampS: t,
            index: i + 1,
            sizeBytes: bytes.length,
          ),
        );

        if ((i + 1) % 5 == 0 || i + 1 == pts.length) {
          await history.recordProgress(
            videoPath: videoInfo.path,
            savedCount: i + 1,
            total: pts.length,
            totalBytes: totalBytes,
          );
        }

        final avg = sw.elapsedMilliseconds / ((i - resumeFromIndex) + 1);
        final remMs = (avg * (pts.length - (i + 1))).round();
        progress.updateProgress(
          current: i + 1,
          remaining: Duration(milliseconds: remMs),
        );
      }

      await history.recordCompleted(
        videoPath: videoInfo.path,
        total: pts.length,
        totalBytes: totalBytes,
      );
      await ref.read(historyProvider.notifier).refresh();
      ref.read(resultsProvider.notifier).setFrames(extractedFrames, videoStem: stem);
      progress.complete(pts.length);
    } on OutputNotWritableException catch (e) {
      progress.setError(e.message);
    } catch (e) {
      progress.setError(e.toString());
    }
  }

  Future<List<String>> saveMarked(VideoInfo v, Set<int> markedFrames) async {
    if (markedFrames.isEmpty) return [];
    final s = ref.read(settingsProvider);
    final reg = GalleryNameRegistry(gallery);
    final stem = _stem(v.path);
    final sub = s.resolveSubfolder(stem);
    final uris = <String>[];
    final sorted = markedFrames.toList()..sort();
    for (final idx in sorted) {
      final ts = v.timeForFrame(idx);
      try {
        final bytes = await engine.getFrame(
          ts,
          exact: true,
          format: s.format.name,
          quality: s.jpegQuality,
        );
        final raw = buildName(
          stem: stem,
          index: idx,
          ts: ts,
          ext: s.format.ext,
          template: '{stem}_{index:06d}_{time}.{ext}',
        );
        final name = await uniqueName(reg, raw);
        final uri = await gallery.writeImage(
          bytes: bytes,
          displayName: name,
          mimeType: s.format.mimeType,
          subfolder: sub,
        );
        reg.recordCreated(name);
        uris.add(uri);
      } catch (_) {}
    }
    if (uris.isNotEmpty) {
      await history.recordCompleted(
        videoPath: v.path,
        total: uris.length,
        totalBytes: uris.length * 250 * 1024,
      );
    }
    return uris;
  }
}
