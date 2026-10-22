class DomainException implements Exception {
  final String title;
  final String message;
  final String detail;
  final String advice;

  const DomainException(
    this.message, {
    this.title = 'Terjadi kesalahan',
    this.detail = '',
    this.advice = '',
  });

  @override
  String toString() => message;
}

class InputException extends DomainException {
  const InputException(
    super.message, {
    super.title = 'Masukan tidak valid',
    super.detail,
    super.advice,
  });
}

class VideoNotFoundException extends InputException {
  const VideoNotFoundException(
    super.message, {
    super.title = 'Berkas tidak ditemukan',
    super.detail,
    super.advice,
  });
}

class UnsupportedVideoException extends InputException {
  const UnsupportedVideoException(
    super.message, {
    super.title = 'Berkas bukan video yang didukung',
    super.detail,
    super.advice,
  });
}

class MetadataException extends InputException {
  const MetadataException(
    super.message, {
    super.title = 'Metadata video tidak terbaca',
    super.detail,
    super.advice,
  });
}

class InvalidOptionException extends InputException {
  const InvalidOptionException(
    super.message, {
    super.title = 'Setelan tidak valid',
    super.detail,
    super.advice,
  });
}

class OutputNotWritableException extends DomainException {
  const OutputNotWritableException(
    super.message, {
    super.title = 'Folder keluaran tidak dapat ditulis',
    super.detail,
    super.advice,
  });
}

class InsufficientDiskSpaceException extends DomainException {
  const InsufficientDiskSpaceException(
    super.message, {
    super.title = 'Ruang disk tidak cukup',
    super.detail,
    super.advice,
  });
}

class EngineUnavailableException extends DomainException {
  const EngineUnavailableException(
    super.message, {
    super.title = 'Mesin ekstraksi tidak tersedia',
    super.detail,
    super.advice,
  });
}

class ExtractionFailedException extends DomainException {
  final List<dynamic> partialResults;

  const ExtractionFailedException(
    super.message, {
    super.title = 'Ekstraksi gagal',
    super.detail,
    super.advice,
    this.partialResults = const [],
  });
}

class PlanException extends InputException {
  const PlanException(
    super.message, {
    super.title = 'Tidak ada frame yang bisa diambil',
    super.detail,
    super.advice,
  });
}
