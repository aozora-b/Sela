import '../domain/name_registry.dart';
import '../engine/gallery_writer.dart';

class GalleryNameRegistry implements NameRegistry {
  final GalleryWriter _writer;
  final Set<String> _knownNames;

  GalleryNameRegistry(this._writer, {Set<String>? initialNames})
    : _knownNames = Set<String>.from(initialNames ?? const <String>{});

  @override
  Future<bool> exists(String name) async {
    if (_knownNames.contains(name)) return true;
    final existsInStorage = await _writer.exists(name);
    if (existsInStorage) {
      _knownNames.add(name);
      return true;
    }
    return false;
  }

  void recordCreated(String name) {
    _knownNames.add(name);
  }
}
