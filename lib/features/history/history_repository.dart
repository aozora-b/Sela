import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/session_models.dart';

class HistoryRepository {
  static const _historyKey = 'extraction_history_list';
  static const _activePrefix = 'active_session_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<ExtractionSession>> getHistory() async {
    final prefs = await _prefs;
    final raw = prefs.getStringList(_historyKey) ?? [];
    return raw
        .map(
          (str) => ExtractionSession.fromJson(
            jsonDecode(str) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> addHistory(ExtractionSession session) async {
    final prefs = await _prefs;
    final current = await getHistory();
    current.insert(0, session);
    final encoded = current.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<void> deleteHistory(String id) async {
    final prefs = await _prefs;
    final current = await getHistory();
    current.removeWhere((s) => s.id == id);
    final encoded = current.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<ExtractionSession?> getActiveSession(String videoPath) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_activePrefix$videoPath');
    if (raw == null) return null;
    return ExtractionSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveActiveSession(ExtractionSession session) async {
    final prefs = await _prefs;
    await prefs.setString(
      '$_activePrefix${session.videoPath}',
      jsonEncode(session.toJson()),
    );
  }

  Future<void> clearActiveSession(String videoPath) async {
    final prefs = await _prefs;
    await prefs.remove('$_activePrefix$videoPath');
  }

  Future<void> recordProgress({
    required String videoPath,
    required int savedCount,
    required int total,
    required int totalBytes,
  }) async {
    await saveActiveSession(
      ExtractionSession(
        id: '${videoPath}_active',
        videoPath: videoPath,
        savedCount: savedCount,
        lastIndex: savedCount,
        total: total,
        timestamp: DateTime.now(),
        totalSizeBytes: totalBytes,
      ),
    );
  }

  Future<void> recordCompleted({
    required String videoPath,
    required int total,
    required int totalBytes,
  }) async {
    await clearActiveSession(videoPath);
    await addHistory(
      ExtractionSession(
        id: '${videoPath}_${DateTime.now().millisecondsSinceEpoch}',
        videoPath: videoPath,
        savedCount: total,
        lastIndex: total,
        total: total,
        timestamp: DateTime.now(),
        totalSizeBytes: totalBytes,
      ),
    );
  }
}

final historyRepositoryProvider = Provider((ref) => HistoryRepository());
