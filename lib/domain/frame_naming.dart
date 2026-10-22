import 'exceptions.dart';
import 'name_registry.dart';

final _forbidden = RegExp(r'[\\/:*?"<>|\x00-\x1f]');
final _trailing = RegExp(r'[ .]+$');
final _reserved = {
  'CON',
  'PRN',
  'AUX',
  'NUL',
  'CONIN\$',
  'CONOUT\$',
  for (var i = 1; i <= 9; i++) 'COM$i',
  for (var i = 1; i <= 9; i++) 'LPT$i',
};

const _maxNameLength = 180;

String sanitizeStem(String name, {String fallback = 'video'}) {
  var cleaned = name
      .replaceAll(_forbidden, '_')
      .replaceAll(_trailing, '')
      .trim();
  if (cleaned.isEmpty) cleaned = fallback;
  if (_reserved.contains(cleaned.toUpperCase())) cleaned = '_$cleaned';
  return cleaned.length > _maxNameLength
      ? cleaned.substring(0, _maxNameLength)
      : cleaned;
}

String sanitizeFilename(String name, {String fallback = 'frame'}) {
  var cleaned = name
      .replaceAll(_forbidden, '_')
      .replaceAll(_trailing, '')
      .trim();
  if (cleaned.isEmpty) cleaned = fallback;
  final stem = cleaned.split('.')[0];
  if (_reserved.contains(stem.toUpperCase())) cleaned = '_$cleaned';
  return cleaned.length > _maxNameLength
      ? cleaned.substring(0, _maxNameLength)
      : cleaned;
}

String formatTime(double seconds) {
  if (!seconds.isFinite || seconds < 0) seconds = 0.0;
  final total = seconds.floor();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  return '${h.toString().padLeft(2, '0')}-${m.toString().padLeft(2, '0')}-${s.toString().padLeft(2, '0')}';
}

void validateTemplate(String template) {
  if (template.trim().isEmpty) {
    throw const InvalidOptionException('Pola nama berkas tidak boleh kosong.');
  }

  final placeholderRegExp = RegExp(r'\{([^{}]+)\}');
  final matches = placeholderRegExp.allMatches(template);

  if (matches.isEmpty) {
    throw const InvalidOptionException(
      'Pola nama berkas harus memuat {index} dan {ext}.',
    );
  }

  final allowedFields = {'stem', 'index', 'time', 'ext'};
  final fields = <String>{};
  final unknown = <String>{};

  for (final match in matches) {
    final field = match.group(1)!;
    final baseField = field.split(':')[0];
    fields.add(baseField);
    if (!allowedFields.contains(baseField)) unknown.add(baseField);
  }

  if (unknown.isNotEmpty) {
    final unknownList = unknown.toList()..sort();
    throw InvalidOptionException(
      'Pola nama berkas memakai placeholder yang tidak dikenal: '
      '${unknownList.map((e) => '{$e}').join(', ')}. '
      'Gunakan {stem}, {index}, {time}, dan {ext}.',
    );
  }

  if (!fields.contains('index')) {
    throw const InvalidOptionException(
      'Pola nama berkas harus memuat {index} agar urutan konsisten.',
    );
  }
  if (!fields.contains('ext')) {
    throw const InvalidOptionException('Pola nama berkas harus memuat {ext}.');
  }

  try {
    _renderTemplate(template, 'contoh', 1, '00-00-00', 'png');
  } catch (e) {
    throw InvalidOptionException('Pola nama berkas tidak dapat dirender: $e');
  }
}

String _renderTemplate(
  String template,
  String stem,
  int index,
  String time,
  String ext,
) {
  final res = template
      .replaceAll('{stem}', stem)
      .replaceAll('{time}', time)
      .replaceAll('{ext}', ext);
  final indexRegExp = RegExp(r'\{index(?::(\d+)d)?\}');
  return res.replaceAllMapped(indexRegExp, (match) {
    final width = match.group(1) != null ? int.parse(match.group(1)!) : 1;
    return index.toString().padLeft(width, '0');
  });
}

String buildName({
  required String stem,
  required int index,
  required double ts,
  required String ext,
  required String template,
}) {
  if (index < 1) throw ArgumentError('index harus dimulai dari 1');

  var normalizedExt = ext.toLowerCase();
  if (normalizedExt.startsWith('.')) {
    normalizedExt = normalizedExt.substring(1);
  }

  if (normalizedExt != 'png' && normalizedExt != 'jpg') {
    throw InvalidOptionException('Ekstensi keluaran tidak didukung: "$ext".');
  }

  validateTemplate(template);

  final rendered = _renderTemplate(
    template,
    sanitizeStem(stem),
    index,
    formatTime(ts),
    normalizedExt,
  );

  var safe = sanitizeFilename(rendered);
  if (!safe.toLowerCase().endsWith('.$normalizedExt')) {
    safe = '$safe.$normalizedExt';
  }

  if (safe.length > _maxNameLength) {
    final suffix = '.$normalizedExt';
    safe =
        safe
            .substring(0, _maxNameLength - suffix.length)
            .replaceAll(_trailing, '') +
        suffix;
  }

  return safe;
}

Future<String> uniqueName(NameRegistry directory, String filename) async {
  if (!await directory.exists(filename)) return filename;

  final lastDot = filename.lastIndexOf('.');
  final stem = lastDot == -1 ? filename : filename.substring(0, lastDot);
  final suffix = lastDot == -1 ? '' : filename.substring(lastDot);

  for (var counter = 1; counter < 100000; counter++) {
    final candidate = '$stem-$counter$suffix';
    if (!await directory.exists(candidate)) return candidate;
  }

  throw const OutputNotWritableException(
    'Terlalu banyak nama berkas yang bentrok.',
    advice: 'Pilih folder keluaran lain atau hapus hasil lama.',
  );
}
