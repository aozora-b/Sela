class ExtractionSession {
  final String id;
  final String videoPath;
  final int savedCount;
  final int lastIndex;
  final int total;
  final DateTime timestamp;
  final int totalSizeBytes;

  const ExtractionSession({
    required this.id,
    required this.videoPath,
    required this.savedCount,
    required this.lastIndex,
    required this.total,
    required this.timestamp,
    this.totalSizeBytes = 0,
  });

  bool get canResume => savedCount > 0 && savedCount < total;

  Map<String, dynamic> toJson() => {
    'id': id,
    'videoPath': videoPath,
    'savedCount': savedCount,
    'lastIndex': lastIndex,
    'total': total,
    'timestamp': timestamp.toIso8601String(),
    'totalSizeBytes': totalSizeBytes,
  };

  factory ExtractionSession.fromJson(Map<String, dynamic> json) {
    return ExtractionSession(
      id: json['id'] as String? ?? '',
      videoPath: json['videoPath'] as String? ?? '',
      savedCount: json['savedCount'] as int? ?? 0,
      lastIndex: json['lastIndex'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      totalSizeBytes: json['totalSizeBytes'] as int? ?? 0,
    );
  }
}
