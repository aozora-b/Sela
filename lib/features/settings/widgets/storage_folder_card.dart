import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../domain/settings_models.dart';
import '../../../engine/video_picker.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';
import '../settings_controller.dart';

class StorageFolderCard extends ConsumerWidget {
  const StorageFolderCard({
    super.key,
    required this.settings,
    required this.notifier,
  });

  final AppSettings settings;
  final SettingsController notifier;

  Future<void> _pickFolder(BuildContext context, WidgetRef ref) async {
    final picker = ref.read(videoPickerProvider);
    final picked = await picker.pickOutputDirectory();
    if (!context.mounted || picked == null) return;

    final treeUri = picked['treeUri'] as String?;
    final displayPath = picked['displayPath'] as String?;
    if (treeUri != null && displayPath != null) {
      await notifier.setOutputDirectory(
        displayPath: displayPath,
        treeUri: treeUri,
      );
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            l10n?.storageFolderChanged(displayPath) ??
                'Folder penyimpanan diubah ke $displayPath',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final hasCustomTree =
        settings.customTreeUri != null && settings.customTreeUri!.isNotEmpty;
    final baseFolder = hasCustomTree
        ? settings.customFolder
        : 'Pictures/${settings.customFolder}';
    final examplePath = settings.organizeByVideo
        ? '$baseFolder/[Nama_Video]/'
        : '$baseFolder/';

    return Material(
      color: colors.surface,
      borderRadius: SelaRadius.cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SwitchListTile(
            value: settings.organizeByVideo,
            onChanged: (val) => notifier.setOrganizeByVideo(val),
            title: Text(
              l10n.labelOrganizeByVideo,
              style: SelaText.body.copyWith(color: colors.textPrimary),
            ),
            subtitle: Text(
              l10n.subOrganizeByVideo,
              style: SelaText.caption.copyWith(color: colors.textSecondary),
            ),
          ),
          Divider(height: 1, color: colors.border),
          ListTile(
            onTap: () => _pickFolder(context, ref),
            leading: Icon(
              Icons.folder_open_rounded,
              color: colors.accent,
            ),
            title: Text(
              l10n.labelPickFolder,
              style: SelaText.body.copyWith(color: colors.textPrimary),
            ),
            subtitle: Text(
              examplePath,
              style: SelaText.caption.copyWith(color: colors.accent),
            ),
            trailing: hasCustomTree
                ? IconButton(
                    tooltip: l10n.tooltipResetDefault,
                    icon: Icon(
                      Icons.restart_alt_rounded,
                      color: colors.textSecondary,
                    ),
                    onPressed: () => notifier.resetOutputDirectory(),
                  )
                : Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: colors.textSecondary,
                  ),
          ),
        ],
      ),
    );
  }
}
