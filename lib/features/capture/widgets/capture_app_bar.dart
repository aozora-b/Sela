import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';

/// AppBar layar capture saat video sudah terbuka: tombol kembali,
/// nama berkas video, dan chip info resolusi + FPS sesuai mockup.
class CaptureAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CaptureAppBar({super.key, required this.videoInfo});

  final VideoInfo videoInfo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final fileName = videoInfo.path.split(Platform.pathSeparator).last;
    final fpsText = videoInfo.formattedFps;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colors.bgElevated,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        fileName,
        style: SelaText.of(context, SelaText.titleCard),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SelaSpace.md,
            vertical: SelaSpace.xs,
          ),
          margin: const EdgeInsetsDirectional.only(end: SelaSpace.xl),
          decoration: BoxDecoration(
            color: colors.surfaceHighlight,
            borderRadius: SelaRadius.pillBorderRadius,
          ),
          child: Text(
            '${videoInfo.resolution} · $fpsText',
            style: SelaText.caption.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
