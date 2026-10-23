import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import '../../history/history_controller.dart';
import '../../history/history_screen.dart';
import '../../settings/settings_screen.dart';

/// AppBar layar capture saat video sudah terbuka: judul nama berkas,
/// akses Riwayat & Setelan, plus pill resolusi sumber.
class CaptureAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CaptureAppBar({super.key, required this.videoInfo});

  final VideoInfo videoInfo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return AppBar(
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
    );
  }
}
