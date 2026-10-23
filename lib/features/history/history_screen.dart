import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../theme/sela_colors.dart';
import '../../theme/sela_space.dart';
import '../../theme/sela_text.dart';
import 'history_controller.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  String _formatSize(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '±${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: SelaColors.bg,
      appBar: AppBar(
        backgroundColor: SelaColors.bg,
        foregroundColor: SelaColors.textPrimary,
        elevation: 0,
        title: Text(l10n.titleHistory, style: SelaText.titleCard),
      ),
      body: historyAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Text(
                l10n.emptyHistory,
                style: SelaText.body.copyWith(color: SelaColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: SelaSpace.xl,
              vertical: SelaSpace.md,
            ),
            itemCount: sessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: SelaSpace.md),
            itemBuilder: (context, index) {
              final s = sessions[index];
              final stem = s.videoPath.split(Platform.pathSeparator).last;

              return Dismissible(
                key: ValueKey(s.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: SelaSpace.lg),
                  decoration: const BoxDecoration(
                    color: SelaColors.error,
                    borderRadius: SelaRadius.cardBorderRadius,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: SelaColors.textPrimary,
                  ),
                ),
                onDismissed: (_) {
                  ref.read(historyProvider.notifier).deleteSession(s.id);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.sessionDeleted)));
                },
                child: Container(
                  padding: const EdgeInsets.all(SelaSpace.md),
                  decoration: const BoxDecoration(
                    color: SelaColors.surface,
                    borderRadius: SelaRadius.cardBorderRadius,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: SelaColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(SelaRadius.sm),
                        ),
                        child: const Icon(
                          Icons.movie_outlined,
                          color: SelaColors.accent,
                        ),
                      ),
                      const SizedBox(width: SelaSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stem,
                              style: SelaText.body.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: SelaSpace.xs),
                            Text(
                              '${_formatDate(s.timestamp)} · ${l10n.historyTotalFrames(s.savedCount)} · ${_formatSize(s.totalSizeBytes)}',
                              style: SelaText.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: SelaColors.accent),
        ),
        error: (err, _) =>
            Center(child: Text(err.toString(), style: SelaText.caption)),
      ),
    );
  }
}
