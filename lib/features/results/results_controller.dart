import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../domain/models.dart';
import '../../domain/settings_models.dart';
import '../../engine/gallery_writer_channel.dart';
import '../settings/settings_controller.dart';
import 'results_state.dart';

/// State notifier controlling extracted frame review and export operations.
class ResultsController extends Notifier<ResultsState> {
  final _gallery = GalleryWriterChannel();

  @override
  ResultsState build() => const ResultsState();

  /// Sets the extracted frame list with all frames selected by default.
  void setFrames(List<FrameResult> frames, {String videoStem = ''}) {
    state = ResultsState(
      frames: frames,
      selectedIndices: frames.map((f) => f.index).toSet(),
      videoStem: videoStem,
    );
  }

  void toggleSelect(int index) {
    final updated = Set<int>.from(state.selectedIndices);
    if (updated.contains(index)) {
      updated.remove(index);
    } else {
      updated.add(index);
    }
    state = state.copyWith(selectedIndices: updated);
  }

  void selectAll() {
    state = state.copyWith(
      selectedIndices: state.frames.map((f) => f.index).toSet(),
    );
  }

  void deselectAll() {
    state = state.copyWith(selectedIndices: const <int>{});
  }

  void toggleAll() {
    if (state.selectedIndices.length == state.frames.length) {
      deselectAll();
    } else {
      selectAll();
    }
  }

  void deleteSelected() {
    final toDelete = state.frames
        .where((f) => state.selectedIndices.contains(f.index))
        .toList();

    for (final frame in toDelete) {
      try {
        final file = File(frame.path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }

    final remaining = state.frames
        .where((f) => !state.selectedIndices.contains(f.index))
        .toList();

    state = state.copyWith(
      frames: remaining,
      selectedIndices: const <int>{},
    );
  }

  Future<void> saveAll(BuildContext context) async {
    if (state.isSaving) return;
    final s = ref.read(settingsProvider);
    final frames = state.frames;
    if (frames.isEmpty) return;

    state = state.copyWith(isSaving: true);
    try {
      await _saveFramesToGallery(frames, s);
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        final msg = l10n != null
            ? l10n.savedToFolder(frames.length, s.customFolder)
            : '${frames.length} frame tersimpan di ${s.customFolder}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> saveSelected(BuildContext context) async {
    if (state.isSaving) return;
    final s = ref.read(settingsProvider);
    final frames = state.frames
        .where((f) => state.selectedIndices.contains(f.index))
        .toList();
    if (frames.isEmpty) return;

    state = state.copyWith(isSaving: true);
    try {
      await _saveFramesToGallery(frames, s);
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        final msg = l10n != null
            ? l10n.savedToFolder(frames.length, s.customFolder)
            : '${frames.length} frame tersimpan di ${s.customFolder}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      state = state.copyWith(isSaving: false);
    }
  }

  Future<void> _saveFramesToGallery(List<FrameResult> framesToSave, AppSettings s) async {
    String? subfolder;
    final stem = state.videoStem.isNotEmpty
        ? state.videoStem
        : (framesToSave.isNotEmpty
            ? framesToSave.first.path.split(Platform.pathSeparator).last.split('_').first
            : null);
    if (stem != null && stem.isNotEmpty) {
      subfolder = s.resolveSubfolder(stem);
    }

    for (final frame in framesToSave) {
      try {
        final file = File(frame.path);
        if (file.existsSync()) {
          final bytes = await file.readAsBytes();
          final name = frame.path.split(Platform.pathSeparator).last;
          await _gallery.writeImage(
            bytes: bytes,
            displayName: name,
            mimeType: s.format.mimeType,
            subfolder: subfolder,
          );
        }
      } catch (_) {}
    }
  }

  Future<void> shareSelected(BuildContext context) async {
    final framesToShare = state.selectedIndices.isNotEmpty
        ? state.frames.where((f) => state.selectedIndices.contains(f.index)).toList()
        : state.frames;
    final selectedPaths = framesToShare.map((f) => f.path).toList();
    if (selectedPaths.isEmpty) return;

    try {
      await _gallery.shareImages(selectedPaths);
    } catch (_) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.errorSharePhotos ?? 'Gagal membagikan foto'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

final resultsProvider = NotifierProvider<ResultsController, ResultsState>(
  ResultsController.new,
);
