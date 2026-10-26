import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../domain/models.dart';
import '../../theme/sela_colors.dart';
import '../../theme/sela_space.dart';
import '../../theme/sela_text.dart';
import 'results_controller.dart';
import 'widgets/frame_tile.dart';
import 'widgets/results_bottom_bar.dart';

/// Layar 06: Hasil Ekstraksi (Gallery Grid & Seleksi).
class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key, this.initialFrames = const []});

  final List<FrameResult> initialFrames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(resultsProvider);
    final frames = state.frames.isNotEmpty ? state.frames : initialFrames;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.bg,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: colors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              l10n.titlePhotos(frames.length),
              style: SelaText.titleCard.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.resultsSubtitle,
              style: SelaText.caption.copyWith(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.home_outlined,
              color: colors.textPrimary,
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          const SizedBox(width: SelaSpace.xs),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(SelaSpace.md),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.85,
        ),
        itemCount: frames.length,
        itemBuilder: (context, index) {
          final frame = frames[index];
          final isSelected = state.selectedIndices.contains(frame.index);
          return FrameTile(
            frame: frame,
            isSelected: isSelected,
            onTap: () => ref
                .read(resultsProvider.notifier)
                .toggleSelect(frame.index),
          );
        },
      ),
      bottomNavigationBar: ResultsBottomBar(
        selectedCount: state.selectedCount,
        totalCount: frames.length,
        isSaving: state.isSaving,
        onDelete: () {
          ref.read(resultsProvider.notifier).deleteSelected();
        },
        onSaveAll: () {
          ref.read(resultsProvider.notifier).saveAll(context);
        },
        onSaveSelected: () {
          ref.read(resultsProvider.notifier).saveSelected(context);
        },
        onShare: () {
          ref.read(resultsProvider.notifier).shareSelected(context);
        },
      ),
    );
  }
}
