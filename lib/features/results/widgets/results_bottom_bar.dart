import 'package:flutter/material.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../../theme/sela_colors.dart';
import '../../../theme/sela_space.dart';
import '../../../theme/sela_text.dart';

/// Bilah aksi bawah pada Layar 06 (Hapus, Simpan Semua, Simpan yang Dipilih, Bagikan).
class ResultsBottomBar extends StatelessWidget {
  const ResultsBottomBar({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onDelete,
    required this.onSaveAll,
    required this.onSaveSelected,
    required this.onShare,
    this.isSaving = false,
  });

  final int selectedCount;
  final int totalCount;
  final VoidCallback onDelete;
  final VoidCallback onSaveAll;
  final VoidCallback onSaveSelected;
  final VoidCallback onShare;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final hasSelection = selectedCount > 0;
    
    // Warna untuk elemen dinonaktifkan mengikuti gambar
    final disabledBg = colors.border.withValues(alpha: 0.3);
    final disabledFg = colors.textSecondary.withValues(alpha: 0.5);

    return Container(
      padding: EdgeInsetsDirectional.only(
        start: SelaSpace.md,
        end: SelaSpace.md,
        top: SelaSpace.sm,
        bottom: MediaQuery.paddingOf(context).bottom + SelaSpace.md,
      ),
      decoration: BoxDecoration(
        color: colors.bgElevated,
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Hapus (Kiri)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasSelection ? colors.error.withValues(alpha: 0.1) : disabledBg,
            ),
            child: IconButton(
              tooltip: l10n.btnDelete,
              onPressed: hasSelection ? onDelete : null,
              icon: Icon(
                Icons.delete_outline,
                color: hasSelection ? colors.error : disabledFg,
                size: 24,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: SelaSpace.xs),
          
          // Tombol Simpan Semua (Tengah Kiri)
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: (totalCount > 0 && !isSaving) ? onSaveAll : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: disabledBg,
                  disabledForegroundColor: disabledFg,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.btnSaveAll,
                  style: SelaText.button.copyWith(fontSize: 13, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: SelaSpace.xs),
          
          // Tombol Simpan yang Dipilih (Tengah Kanan)
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: (hasSelection && !isSaving) ? onSaveSelected : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelection ? colors.bgElevated : disabledBg,
                  foregroundColor: hasSelection ? colors.textPrimary : disabledFg,
                  disabledBackgroundColor: disabledBg,
                  disabledForegroundColor: disabledFg,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(
                      color: hasSelection ? colors.border : Colors.transparent,
                    ),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.btnSaveSelected,
                  style: SelaText.button.copyWith(fontSize: 13, color: hasSelection ? colors.textPrimary : disabledFg),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: SelaSpace.xs),
          
          // Tombol Bagikan (Kanan)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: totalCount > 0
                  ? (hasSelection ? colors.accent.withValues(alpha: 0.15) : colors.bgElevated)
                  : disabledBg,
              border: Border.all(
                color: totalCount > 0
                    ? (hasSelection ? colors.accent : colors.border)
                    : Colors.transparent,
              ),
            ),
            child: IconButton(
              tooltip: l10n.btnShare,
              onPressed: (totalCount > 0 && !isSaving) ? onShare : null,
              icon: Icon(
                Icons.share_outlined,
                color: totalCount > 0
                    ? (hasSelection ? colors.accent : colors.textPrimary)
                    : disabledFg,
                size: 24,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}