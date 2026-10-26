import 'dart:io';

import '../../core/gallery_name_registry.dart';
import '../../domain/frame_naming.dart';
import '../../domain/models.dart';
import '../../domain/settings_models.dart';
import '../../engine/frame_engine_channel.dart';
import '../../engine/gallery_writer_channel.dart';

class FrameSaver {
  const FrameSaver({required this.engine, required this.gallery});

  final FrameEngineChannel engine;
  final GalleryWriterChannel gallery;

  Future<String?> saveSingle({
    required VideoInfo video,
    required double timeS,
    required AppSettings settings,
  }) async {
    try {
      final bytes = await engine.getFrame(
        timeS,
        exact: true,
        format: settings.format.name,
        quality: settings.jpegQuality,
      );
      final idx = ((timeS * video.fps).round() + 1).clamp(1, video.frameCount);
      final stem =
          video.path.split(Platform.pathSeparator).last.split('.').first;
      final raw = buildName(
        stem: stem,
        index: idx,
        ts: timeS,
        ext: settings.format.ext,
        template: '{stem}_{index:06d}_{time}.{ext}',
      );
      final reg = GalleryNameRegistry(gallery);
      final name = await uniqueName(reg, raw);
      final uri = await gallery.writeImage(
        bytes: bytes,
        displayName: name,
        mimeType: settings.format.mimeType,
        subfolder: settings.resolveSubfolder(stem),
      );
      reg.recordCreated(name);
      return uri;
    } catch (_) {
      return null;
    }
  }
}
