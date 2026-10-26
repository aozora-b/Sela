import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../capture_controller.dart';

class FrameFilmstrip extends ConsumerWidget {
  final VideoInfo videoInfo;

  const FrameFilmstrip({super.key, required this.videoInfo});

  void _step(WidgetRef ref, CaptureState state, int delta) {
    final cur = videoInfo.frameForTime(state.currentTime);
    final target = (cur + delta).clamp(1, videoInfo.frameCount);
    HapticFeedback.selectionClick();
    ref.read(captureProvider.notifier).seekTo(videoInfo.timeForFrame(target));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final notifier = ref.read(captureProvider.notifier);
    final currentFrame = videoInfo.frameForTime(state.currentTime);

    var start = (currentFrame - 2).clamp(1, videoInfo.frameCount);
    var end = (currentFrame + 2).clamp(1, videoInfo.frameCount);
    if (end - start < 4) {
      if (start == 1) {
        end = (start + 4).clamp(1, videoInfo.frameCount);
      } else if (end == videoInfo.frameCount) {
        start = (end - 4).clamp(1, videoInfo.frameCount);
      }
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v < -100) _step(ref, state, 1);
        if (v > 100) _step(ref, state, -1);
      },
      child: Center(
        child: Wrap(
          spacing: SelaSpace.sm,
          alignment: WrapAlignment.center,
          children: [
            for (var idx = start; idx <= end; idx++)
              _ThumbnailTile(
                key: ValueKey(idx),
                frameIndex: idx,
                timeS: videoInfo.timeForFrame(idx),
                isActive: idx == currentFrame,
                isMarked: state.markedFrames.contains(idx),
                isScrubbing: state.isScrubbing,
                exactBytes: notifier.getCachedThumbnail(idx),
                placeholderBytes: notifier.getNearestThumbnail(idx) ?? state.activeFrame,
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.seekTo(videoInfo.timeForFrame(idx));
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailTile extends ConsumerStatefulWidget {
  final int frameIndex;
  final double timeS;
  final bool isActive;
  final bool isMarked;
  final bool isScrubbing;
  final Uint8List? exactBytes;
  final Uint8List? placeholderBytes;
  final VoidCallback onTap;

  const _ThumbnailTile({
    super.key,
    required this.frameIndex,
    required this.timeS,
    required this.isActive,
    required this.isMarked,
    required this.isScrubbing,
    required this.exactBytes,
    required this.placeholderBytes,
    required this.onTap,
  });

  @override
  ConsumerState<_ThumbnailTile> createState() => _ThumbnailTileState();
}

class _ThumbnailTileState extends ConsumerState<_ThumbnailTile> {
  Uint8List? _loadedBytes;

  @override
  void initState() {
    super.initState();
    _loadedBytes = widget.exactBytes;
    _ensureLoaded();
  }

  @override
  void didUpdateWidget(covariant _ThumbnailTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exactBytes != null) {
      _loadedBytes = widget.exactBytes;
    } else if (oldWidget.frameIndex != widget.frameIndex ||
        (oldWidget.isScrubbing && !widget.isScrubbing)) {
      _loadedBytes = null;
      _ensureLoaded();
    }
  }

  void _ensureLoaded() {
    if (_loadedBytes != null || widget.isScrubbing) return;
    final notifier = ref.read(captureProvider.notifier);
    final cached = notifier.getCachedThumbnail(widget.frameIndex);
    if (cached != null) {
      _loadedBytes = cached;
      return;
    }
    final targetIdx = widget.frameIndex;
    unawaited(
      notifier.getThumbnail(targetIdx, widget.timeS).then((bytes) {
        if (mounted && bytes != null && widget.frameIndex == targetIdx) {
          setState(() => _loadedBytes = bytes);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayBytes = _loadedBytes ?? widget.exactBytes ?? widget.placeholderBytes;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        HapticFeedback.selectionClick();
        ref.read(captureProvider.notifier).toggleMarkFrame(widget.frameIndex);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 58,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SelaRadius.sm),
          border: Border.all(
            color: widget.isActive ? colors.accent : colors.border,
            width: widget.isActive ? 2.5 : 1.0,
          ),
          color: colors.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (displayBytes != null)
              Image.memory(displayBytes, fit: BoxFit.cover, cacheWidth: 116, gaplessPlayback: true)
            else
              ColoredBox(
                color: colors.surfaceHighlight,
                child: Center(
                  child: Icon(Icons.movie_outlined, size: 20, color: colors.textSecondary.withValues(alpha: 0.5)),
                ),
              ),
            if (widget.isMarked)
              Positioned(
                top: 2, right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: colors.accent, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 9, color: Colors.white),
                ),
              ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.65),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    '${widget.frameIndex}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
