import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../domain/session_models.dart';
import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';

/// Kartu akses cepat untuk melanjutkan sesi ekstraksi terakhir yang belum selesai.
class QuickAccessCard extends ConsumerWidget {
  const QuickAccessCard({
    super.key,
    required this.session,
    required this.onResume,
  });

  final ExtractionSession session;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final fileName = session.videoPath.split(RegExp(r'[/\\]')).last;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SelaSpace.md),
      decoration: BoxDecoration(
        color: colors.bgElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.history_rounded, color: colors.accent, size: 24),
          ),
          const SizedBox(width: SelaSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SelaText.of(
                    context,
                    SelaText.titleCard,
                  ).copyWith(fontSize: 14, color: colors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.savedCount} / ${session.total} frame',
                  style: SelaText.caption.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: SelaSpace.sm),
          TextButton(
            onPressed: onResume,
            style: TextButton.styleFrom(
              foregroundColor: colors.accent,
              padding: const EdgeInsets.symmetric(horizontal: SelaSpace.md),
            ),
            child: Text(l10n.btnResume),
          ),
        ],
      ),
    );
  }
}
