import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../engine/video_picker.dart';
import '../../theme/sela_colors.dart';
import '../../theme/sela_space.dart';
import '../../theme/sela_text.dart';
import 'capture_controller.dart';
import 'resume_flow.dart';
import 'thumbnail_cache.dart';
import 'widgets/capture_app_bar.dart';
import 'widgets/capture_bottom_bar.dart';
import 'widgets/interval_selector.dart';
import 'widgets/mode_switch.dart';
import 'widgets/nudge_controls.dart';
import 'widgets/timeline_scrubber.dart';
import 'widgets/video_preview.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  @override
  void initState() {
    super.initState();
    ThumbnailCache.trimImageCache();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final path = ref.read(captureProvider).videoInfo?.path;
      if (path != null) {
        runResumeFlow(context, ref, path);
      }
    });
  }

  @override
  void dispose() {
    ThumbnailCache.flushImageCache();
    super.dispose();
  }

  Future<void> _pickAndOpen() async {
    final result = await ref.read(videoPickerProvider).pickVideo();
    if (!mounted || result == null) return;
    final path = result['path'] as String;
    await ref.read(captureProvider.notifier).openVideo(path);
    if (!mounted) return;
    await runResumeFlow(context, ref, path);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(captureProvider);
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();
    final colors = context.colors;

    final videoInfo = state.videoInfo;
    if (videoInfo == null) {
      return Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: colors.bgElevated,
          title: Text(
            l10n.titleCapture,
            style: SelaText.of(context, SelaText.titleCard),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SelaSpace.xl),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickAndOpen,
                child: Text(l10n.btnPickVideo),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: CaptureAppBar(videoInfo: videoInfo),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VideoPreview(videoInfo: videoInfo, activeFrame: state.activeFrame),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(
                top: 0,
                bottom: MediaQuery.paddingOf(context).bottom + SelaSpace.xl,
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: SelaSpace.screenHorizontal,
                    child: TimelineScrubber(),
                  ),
                  const SizedBox(height: SelaSpace.xl),
                  const ModeSwitch(),
                  const SizedBox(height: SelaSpace.xxl),
                  if (state.isExactMode)
                    NudgeControls(videoInfo: videoInfo)
                  else
                    const IntervalSelector(),
                  const SizedBox(height: SelaSpace.xxl),
                  const CaptureBottomBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
