import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sela/l10n/generated/app_localizations.dart';

import '../../domain/sample_plan.dart';
import '../history/history_repository.dart';
import '../progress/progress_sheet.dart';
import 'capture_controller.dart';
import 'widgets/resume_dialog.dart';

/// Alur lanjutan (resume) yang dibagikan oleh [HomeScreen] dan [CaptureScreen].
///
/// Memeriksa sesi aktif untuk [path]; bila sesi dapat dilanjutkan, menampilkan
/// dialog konfirmasi lalu melanjutkan ekstraksi dari frame terakhir, atau
/// menghapus sesi bila pengguna memilih mulai ulang.
Future<void> runResumeFlow(
  BuildContext context,
  WidgetRef ref,
  String path,
) async {
  final session = await ref
      .read(historyRepositoryProvider)
      .getActiveSession(path);
  if (!context.mounted || session == null) return;
  if (session.canResume) {
    final l10n = AppLocalizations.of(context)!;
    final resume = await showDialog<bool>(
      context: context,
      builder: (_) => ResumeDialog(nextFrame: session.savedCount + 1),
    );

    if (!context.mounted) return;
    if (resume == true) {
      unawaited(ProgressSheet.show(context));
      unawaited(
        ref
            .read(captureProvider.notifier)
            .startExtraction(
              errorMessage: l10n.errorMaxFramesExceeded(maxFrames),
              resumeFromIndex: session.savedCount,
            ),
      );
    } else {
      await ref.read(historyRepositoryProvider).clearActiveSession(path);
    }
  }
}
