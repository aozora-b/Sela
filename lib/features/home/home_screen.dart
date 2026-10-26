import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../engine/video_picker.dart';
import '../../theme/sela_colors.dart';
import '../../theme/sela_space.dart';
import '../../theme/sela_text.dart';
import '../capture/capture_controller.dart';
import '../capture/capture_screen.dart';
import '../history/history_controller.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/folder_videos_sheet.dart';
import 'widgets/home_wordmark.dart';
import 'widgets/import_drop_zone.dart';
import 'widgets/pick_folder_button.dart';

/// Main home screen hosting the 3-tab navigation shell (Extract, History, Settings).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _openVideoPath(String path) async {
    try {
      await ref.read(captureProvider.notifier).openVideo(path);
      if (!mounted) return;
      unawaited(
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CaptureScreen()),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorFailedExtract),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickAndOpen() async {
    final picker = ref.read(videoPickerProvider);
    final result = await picker.pickVideo();
    if (!mounted || result == null) return;
    final path = result['path'] as String;
    await _openVideoPath(path);
  }

  Future<void> _onPickFolder() async {
    final picker = ref.read(videoPickerProvider);
    final videos = await picker.pickFolder();
    if (!mounted || videos == null) return;
    if (videos.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Tidak ada berkas video di folder ini'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await FolderVideosSheet.show(
      context: context,
      videos: videos,
      onSelect: (uri) async {
        final copied = await picker.copyVideoUri(uri);
        if (copied != null && mounted) {
          final path = copied['path'] as String;
          await _openVideoPath(path);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return const SizedBox.shrink();
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(l10n, colors),
          const HistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.bgElevated,
          border: Border(top: BorderSide(color: colors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) {
            if (i == 1) {
              unawaited(ref.read(historyProvider.notifier).refresh());
            }
            setState(() => _selectedIndex = i);
          },
          backgroundColor: colors.bgElevated,
          selectedItemColor: colors.accent,
          unselectedItemColor: colors.textSecondary,
          selectedLabelStyle: SelaText.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: SelaText.caption,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.crop_free_rounded),
              activeIcon: const Icon(Icons.crop_free_rounded),
              label: l10n.tabExtract,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_rounded),
              activeIcon: const Icon(Icons.history_rounded),
              label: l10n.titleHistory,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings_rounded),
              label: l10n.titleSettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(AppLocalizations l10n, SelaColorsData colors) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: SelaSpace.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: SelaSpace.xl),
                    const HomeWordmark(),
                    const SizedBox(height: SelaSpace.xxl),
                    Text(
                      l10n.homeHeadline,
                      style: const TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: 38,
                        height: 1.15,
                        fontWeight: FontWeight.normal,
                      ).copyWith(color: colors.textPrimary),
                    ),
                    const SizedBox(height: SelaSpace.md),
                    Text(
                      l10n.homeSubtitle,
                      style: SelaText.body.copyWith(
                        color: colors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: SelaSpace.xxl),
                    ImportDropZone(onTap: _pickAndOpen),
                    const SizedBox(height: SelaSpace.lg),
                    PickFolderButton(onPressed: _onPickFolder),
                    const Spacer(),
                    const SizedBox(height: SelaSpace.xl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
