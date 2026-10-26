import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../domain/session_models.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';

class HistoryCard extends StatelessWidget {
  final ExtractionSession session;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.session,
    required this.onDelete,
    required this.onTap,
  });

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final stem = session.videoPath.split(Platform.pathSeparator).last;

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: SelaSpace.lg),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: SelaRadius.cardBorderRadius,
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Material(
        color: colors.surface,
        borderRadius: SelaRadius.cardBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: SelaRadius.cardBorderRadius,
          child: Padding(
            padding: const EdgeInsets.all(SelaSpace.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(SelaRadius.sm),
                  ),
                  child: Icon(Icons.movie_outlined, color: colors.accent),
                ),
                const SizedBox(width: SelaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stem,
                        style: SelaText.body.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: SelaSpace.xs),
                      Text(
                        '${_formatDate(session.timestamp)} · ${l10n.historyTotalFrames(session.savedCount)}',
                        style: SelaText.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colors.textSecondary),
                  tooltip: l10n.btnDelete,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
