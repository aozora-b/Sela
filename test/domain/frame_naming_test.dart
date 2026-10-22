import 'package:flutter_test/flutter_test.dart';
import 'package:sela/domain/frame_naming.dart';
import 'package:sela/domain/exceptions.dart';
import 'package:sela/domain/name_registry.dart';

class _FakeRegistry implements NameRegistry {
  _FakeRegistry(this.existing);
  final Set<String> existing;
  @override
  Future<bool> exists(String name) => Future.value(existing.contains(name));
}

class _AlwaysExistsRegistry implements NameRegistry {
  @override
  Future<bool> exists(String name) => Future.value(true);
}

void main() {
  const tpl = '{stem}_{index:06d}_{time}.{ext}';

  group('sanitizeStem', () {
    test('membuang karakter terlarang Windows', () {
      final r = sanitizeStem('liburan:2024*"<>|?');
      for (final c in [':', '*', '"', '<', '>', '|', '?']) {
        expect(r.contains(c), isFalse);
      }
    });

    test('memangkas titik dan spasi di ujung', () {
      expect(sanitizeStem('video...   '), 'video');
      expect(sanitizeStem('   '), 'video');
      expect(sanitizeStem('  nama  '), 'nama');
    });

    test('nama reserved diberi awalan garis bawah', () {
      for (final n in ['CON', 'con', 'PRN', 'NUL', 'COM1', 'lpt9']) {
        expect(sanitizeStem(n).toUpperCase().startsWith('_'), isTrue);
      }
    });

    test('mempertahankan unicode', () {
      expect(sanitizeStem('Liburan di Bali — 2024'), 'Liburan di Bali — 2024');
    });
  });

  test('sanitizeFilename memblokir pemisah path', () {
    final r = sanitizeFilename('../../etc/passwd.png');
    expect(r.contains('/'), isFalse);
    expect(r.contains(r'\'), isFalse);
  });

  group('formatTime', () {
    test('memetakan detik ke HH-MM-SS', () {
      expect(formatTime(0), '00-00-00');
      expect(formatTime(3), '00-00-03');
      expect(formatTime(123), '00-02-03');
      expect(formatTime(3661), '01-01-01');
      expect(formatTime(-5), '00-00-00');
    });
  });

  group('buildName', () {
    test('pola bawaan', () {
      expect(buildName(stem: 'liburan', index: 123, ts: 123, ext: 'png', template: tpl),
          'liburan_000123_00-02-03.png');
    });

    test('mulai dari 1 dengan enam digit', () {
      expect(buildName(stem: 'a', index: 1, ts: 0, ext: 'jpg', template: tpl),
          'a_000001_00-00-00.jpg');
    });

    test('membersihkan stem', () {
      expect(buildName(stem: 'a:b*c', index: 1, ts: 0, ext: 'png', template: tpl),
          'a_b_c_000001_00-00-00.png');
    });

    test('menolak template tanpa {ext}', () {
      expect(() => buildName(stem: 'a', index: 1, ts: 0, ext: 'png',
          template: '{stem}_{index:06d}'), throwsA(isA<InvalidOptionException>()));
    });

    test('menolak ekstensi tidak dikenal', () {
      expect(() => buildName(stem: 'a', index: 1, ts: 0, ext: 'gif', template: tpl),
          throwsA(isA<InvalidOptionException>()));
    });

    test('tidak mengizinkan path traversal', () {
      final r = buildName(stem: 'a', index: 1, ts: 0, ext: 'png',
          template: '../{stem}_{index:06d}.{ext}');
      expect(r.contains('/'), isFalse);
      expect(r.contains(r'\'), isFalse);
    });

    test('nama panjang dipotong di 180 karakter', () {
      final r = buildName(stem: 'x' * 400, index: 1, ts: 0, ext: 'png', template: tpl);
      expect(r.length, lessThanOrEqualTo(180));
      expect(r.endsWith('.png'), isTrue);
    });
  });

  group('validateTemplate', () {
    test('menolak pola buruk', () {
      for (final t in ['', '   ', '{stem}_{index:06d}_{unknown}.{ext}',
                       '{stem}_{time}.{ext}', '{stem}_{index:06d}',
                       '{stem}_{index:06d_{time}.{ext}']) {
        expect(() => validateTemplate(t), throwsA(isA<InvalidOptionException>()),
            reason: 'harus menolak: $t');
      }
    });
  });

  group('anti-tabrakan unik', () {
    test('menambahkan sufiks saat nama sudah dipakai', () async {
      final reg = _FakeRegistry({'frame.png', 'frame-1.png'});
      expect(await uniqueName(reg, 'frame.png'), 'frame-2.png');
    });

    test('nama lama tidak pernah tertimpa', () async {
      final reg = _FakeRegistry({'hasil_000001_00-00-00.png'});
      final chosen = await uniqueName(reg, 'hasil_000001_00-00-00.png');
      expect(chosen, isNot('hasil_000001_00-00-00.png'));
    });

    test('melempar galat saat percobaan habis', () async {
      final reg = _AlwaysExistsRegistry();
      expect(() => uniqueName(reg, 'a.png'), throwsA(isA<OutputNotWritableException>()));
    });
  });
}
