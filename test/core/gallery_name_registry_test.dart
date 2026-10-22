import 'package:flutter_test/flutter_test.dart';
import 'package:sela/core/gallery_name_registry.dart';
import 'package:sela/engine/gallery_writer.dart';

class FakeGalleryWriter implements GalleryWriter {
  final Set<String> existingNames = {};
  final List<String> writtenNames = [];

  @override
  Future<bool> exists(String displayName) async {
    return existingNames.contains(displayName);
  }

  @override
  Future<String> writeImage({
    required List<int> bytes,
    required String displayName,
    required String mimeType,
  }) async {
    writtenNames.add(displayName);
    existingNames.add(displayName);
    return 'content://media/external/images/media/${writtenNames.length}';
  }

  @override
  Future<bool> openGallery() async => true;
}

void main() {
  group('GalleryNameRegistry', () {
    test('returns true if name is in initial names', () async {
      final fake = FakeGalleryWriter();
      final registry = GalleryNameRegistry(
        fake,
        initialNames: {'frame_01.png'},
      );
      expect(await registry.exists('frame_01.png'), isTrue);
      expect(await registry.exists('frame_02.png'), isFalse);
    });

    test('queries gallery writer and caches positive results', () async {
      final fake = FakeGalleryWriter()..existingNames.add('existing.png');
      final registry = GalleryNameRegistry(fake);

      expect(await registry.exists('existing.png'), isTrue);
      fake.existingNames.clear(); // remove from writer
      expect(await registry.exists('existing.png'), isTrue); // cached
    });

    test('recordCreated adds name to local cache', () async {
      final fake = FakeGalleryWriter();
      final registry = GalleryNameRegistry(fake);

      expect(await registry.exists('new_frame.png'), isFalse);
      registry.recordCreated('new_frame.png');
      expect(await registry.exists('new_frame.png'), isTrue);
    });
  });
}
