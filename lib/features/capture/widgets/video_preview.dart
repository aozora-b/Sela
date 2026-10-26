import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../domain/models.dart';

class VideoPreview extends StatelessWidget {
  final VideoInfo videoInfo;
  final Uint8List? activeFrame;

  const VideoPreview({
    super.key,
    required this.videoInfo,
    required this.activeFrame,
  });

  @override
  Widget build(BuildContext context) {
    final aspectRatio = videoInfo.width > 0 && videoInfo.height > 0
        ? videoInfo.width / videoInfo.height
        : 16 / 9;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.4,
      ),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: activeFrame != null
            ? Image.memory(
                activeFrame!,
                fit: BoxFit.contain,
                cacheWidth: 540,
                gaplessPlayback: true,
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
