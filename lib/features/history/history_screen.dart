import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../theme/sela_colors.dart';
import '../../theme/sela_space.dart';
import '../../theme/sela_text.dart';
import 'history_controller.dart';
import 'widgets/history_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgElevated,
        title: Text(l10n.titleDeleteSession, style: SelaText.titleCard),
        content: Text(l10n.confirmDeleteSession, style: SelaText.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.btnCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteImmediately(context, ref, id, l10n);
            },
            child: Text(
              l10n.btnDelete,
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteImmediately(
    BuildContext context,
    WidgetRef ref,
    String id,
    AppLocalizations l10n,
  ) {
    ref.read(historyProvider.notifier).deleteSession(id);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(l10n.sessionDeleted),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(historyProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          l10n.titleHistory,
          style: SelaText.titleCard.copyWith(color: colors.textPrimary),
        ),
      ),
      body: historyAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Text(
                l10n.emptyHistory,
                style: SelaText.body.copyWith(color: colors.textSecondary),
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
              return HistoryCard(
                session: s,
                onDelete: () => _deleteImmediately(context, ref, s.id, l10n),
                onTap: () => _confirmDelete(context, ref, s.id, l10n),
              );
            },
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: colors.accent)),
        error: (err, _) => Center(
          child: Text(
            err.toString(),
            style: SelaText.caption.copyWith(color: colors.textSecondary),
          ),
        ),
      ),
    );
  }
}
