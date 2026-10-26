import 'package:flutter/material.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';

class FolderVideosSheet extends StatelessWidget {
  final List<Map<String, dynamic>> videos;
  final ValueChanged<String> onSelect;

  const FolderVideosSheet({
    super.key,
    required this.videos,
    required this.onSelect,
  });

  static Future<void> show({
    required BuildContext context,
    required List<Map<String, dynamic>> videos,
    required ValueChanged<String> onSelect,
  }) {
    final colors = context.colors;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FolderVideosSheet(videos: videos, onSelect: onSelect),
    );
  }

  String _formatSize(dynamic size) {
    if (size is! num) return '';
    final mb = size / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.35,
      expand: false,
      builder: (_, scroll) => Column(
        children: [
          const SizedBox(height: SelaSpace.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.surfaceHighlight,
              borderRadius: SelaRadius.pillBorderRadius,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SelaSpace.md),
            child: Text(
              l10n?.titleSelectVideoCount(videos.length) ??
                  'Pilih Video (${videos.length})',
              style: SelaText.titleCard.copyWith(color: colors.textPrimary),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: scroll,
              padding: const EdgeInsets.symmetric(
                horizontal: SelaSpace.lg,
                vertical: SelaSpace.sm,
              ),
              itemCount: videos.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final v = videos[index];
                final name = v['name'] as String? ?? 'Video';
                final uri = v['uri'] as String? ?? '';
                final sizeStr = _formatSize(v['size']);

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(SelaRadius.sm),
                    ),
                    child: Icon(Icons.movie_outlined, color: colors.accent),
                  ),
                  title: Text(
                    name,
                    style: SelaText.body.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: sizeStr.isNotEmpty
                      ? Text(
                          sizeStr,
                          style: SelaText.caption.copyWith(
                            color: colors.textSecondary,
                          ),
                        )
                      : null,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: colors.textSecondary,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect(uri);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
