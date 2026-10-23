import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../domain/sample_plan.dart';
import '../../theme/sela_colors.dart';
import '../../theme/sela_space.dart';
import '../../theme/sela_text.dart';
import '../history/history_controller.dart';
import '../history/history_repository.dart';
import '../history/history_screen.dart';
import '../progress/progress_sheet.dart';
import '../settings/settings_screen.dart';
import 'capture_controller.dart';
import 'widgets/capture_bottom_bar.dart';
import 'widgets/interval_selector.dart';
import 'widgets/mode_switch.dart';
import 'widgets/nudge_controls.dart';
import 'widgets/resume_dialog.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(captureProvider).videoInfo == null) {
        _initSampleVideo();
      }
    });
  }

  Future<void> _initSampleVideo() async {
    for (final asset in ['assets/test_1080p.mp4', 'assets/test.mp4']) {
      try {
        final byteData = await rootBundle.load(asset);
        final name = asset.split('/').last;
        final tempFile = File('${Directory.systemTemp.path}/$name');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        await ref.read(captureProvider.notifier).openVideo(tempFile.path);
        if (mounted) unawaited(_checkResume(tempFile.path));
        break;
      } catch (_) {}
    }
  }

  Future<void> _checkResume(String path) async {
    final session = await ref
        .read(historyRepositoryProvider)
        .getActiveSession(path);
    if (!mounted || session == null) return;
    if (session.canResume) {
      final l10n = AppLocalizations.of(context)!;
      final resume = await showDialog<bool>(
        context: context,
        builder: (_) => ResumeDialog(nextFrame: session.savedCount + 1),
      );

      if (!mounted) return;
      if (resume == true) {
        unawaited(ProgressSheet.show(context));
        unawaited(
          ref
              .read(captureProvider.notifier)
              .startExtraction(
                errorMessage: l10n.errorMaxFramesExceeded(maxFrames),
                resumeFromIndex: session.savedCount,
              ),
        );
      } else {
        await ref.read(historyRepositoryProvider).clearActiveSession(path);
      }
    }
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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.bgElevated,
        title: Text(
          videoInfo.path.split('/').last,
          style: SelaText.of(context, SelaText.titleCard),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded, color: colors.textPrimary),
            onPressed: () {
              ref.read(historyProvider.notifier).refresh();
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SelaSpace.sm,
              vertical: SelaSpace.xs,
            ),
            margin: const EdgeInsetsDirectional.only(end: SelaSpace.xl),
            decoration: BoxDecoration(
              color: colors.surfaceHighlight,
              borderRadius: SelaRadius.pillBorderRadius,
            ),
            child: Text(
              videoInfo.resolution,
              style: SelaText.caption.copyWith(color: colors.textPrimary),
            ),
          ),
        ],
      ),
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
