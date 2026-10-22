import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../capture_controller.dart';

class FrameFilmstrip extends ConsumerStatefulWidget {
  const FrameFilmstrip({super.key});

  @override
  ConsumerState<FrameFilmstrip> createState() => _FrameFilmstripState();
}

class _FrameFilmstripState extends ConsumerState<FrameFilmstrip> {
  final ScrollController _scrollController = ScrollController();
  static const double _itemSize = 64.0;
  static const double _gap = SelaSpace.sm;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScrollEnd(double duration) {
    if (!_scrollController.hasClients) return;

    // Calculate nearest frame
    final offset = _scrollController.offset;
    const itemWidth = _itemSize + _gap;
    final index = (offset / itemWidth).round();

    // Calculate timestamp for that index (assuming 1 frame per second or so for the filmstrip)
    // Wait, the filmstrip is supposed to show neighboring frames.
    // Typically, filmstrip shows 1 frame per second or 1 frame per tick.
    // Let's assume it represents 1 frame per second for the whole video.
    final targetTime = index.clamp(0, duration.floor()).toDouble();

    // Snap to index
    _scrollController.animateTo(
      index * itemWidth,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );

    HapticFeedback.selectionClick();
    ref.read(captureProvider.notifier).seekTo(targetTime);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(captureProvider);
    if (state.videoInfo == null) return const SizedBox.shrink();

    final duration = state.videoInfo!.durationS;
    if (duration <= 0) return const SizedBox.shrink();

    final itemCount = duration.floor() + 1;

    // Sync scroll with current time if not scrolling
    if (_scrollController.hasClients &&
        !_scrollController.position.isScrollingNotifier.value) {
      final targetOffset = state.currentTime * (_itemSize + _gap);
      if ((_scrollController.offset - targetOffset).abs() > 1.0) {
        _scrollController.jumpTo(targetOffset);
      }
    }

    return SizedBox(
      height: _itemSize,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (notif) {
          _onScrollEnd(duration);
          return true;
        },
        child: ShaderMask(
          shaderCallback: (bounds) {
            final w = bounds.width;
            final fadeStart = w > 24 ? (w - 24) / w : 0.0;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, fadeStart, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.only(
              start: SelaSpace.lg,
              end: SelaSpace.lg,
            ),
            itemCount: itemCount,
            separatorBuilder: (context, index) => const SizedBox(width: _gap),
            itemBuilder: (context, index) {
              final timeS = index.toDouble();
              final isActive = (timeS - state.currentTime).abs() < 0.5;

              return GestureDetector(
                onTap: () {
                  ref.read(captureProvider.notifier).seekTo(timeS);
                },
                child: Container(
                  width: _itemSize,
                  height: _itemSize,
                  decoration: BoxDecoration(
                    borderRadius: SelaRadius.cardBorderRadius.copyWith(
                      topLeft: const Radius.circular(SelaRadius.sm),
                      topRight: const Radius.circular(SelaRadius.sm),
                      bottomLeft: const Radius.circular(SelaRadius.sm),
                      bottomRight: const Radius.circular(SelaRadius.sm),
                    ),
                    border: isActive
                        ? Border.all(color: SelaColors.accent, width: 2)
                        : null,
                    color: SelaColors.surface,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _ThumbnailFuture(timeS: timeS),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ThumbnailFuture extends ConsumerWidget {
  final double timeS;
  const _ThumbnailFuture({required this.timeS});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = ref.read(captureProvider.notifier).getThumbnail(timeS);
    return FutureBuilder<Uint8List?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          );
        }
        return const Icon(Icons.movie, color: SelaColors.textSecondary);
      },
    );
  }
}
