import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../engine/video_picker_channel.dart';
import '../../theme/sela_colors.dart';
import '../../theme/sela_space.dart';
import '../../theme/sela_text.dart';
import '../capture/capture_controller.dart';
import '../capture/capture_screen.dart';
import '../capture/resume_flow.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';

/// Layar beranda Sela: shell tiga tab (Beranda / Riwayat / Setelan).
///
/// Tab Beranda menjadi titik masuk pemilihan video melalui pemilih native
/// (Storage Access Framework), lalu meneruskan ke [CaptureScreen].
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _pickAndOpen() async {
    final result = await VideoPickerChannel().pickVideo();
    if (!mounted || result == null) return;
    final path = result['path'] as String;
    await ref.read(captureProvider.notifier).openVideo(path);
    if (!mounted) return;
    await runResumeFlow(context, ref, path);
    if (!mounted) return;
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const CaptureScreen()));
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: colors.bgElevated,
        indicatorColor: colors.accentSoft,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: colors.textSecondary),
            selectedIcon: Icon(Icons.home_rounded, color: colors.accent),
            label: l10n.titleHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded, color: colors.textSecondary),
            selectedIcon: Icon(Icons.history_rounded, color: colors.accent),
            label: l10n.titleHistory,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: colors.textSecondary),
            selectedIcon: Icon(Icons.settings_rounded, color: colors.accent),
            label: l10n.titleSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(AppLocalizations l10n, SelaColorsData colors) {
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.bgElevated,
        title: Text(
          l10n.titleHome,
          style: SelaText.of(context, SelaText.titleCard),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: SelaSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 56,
                color: colors.textSecondary,
              ),
              const SizedBox(height: SelaSpace.lg),
              Text(
                l10n.titleCapture,
                style: SelaText.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: SelaSpace.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickAndOpen,
                  child: Text(l10n.btnPickVideo),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
