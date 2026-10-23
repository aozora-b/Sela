enum OutputFormat { png, jpeg }

extension OutputFormatX on OutputFormat {
  String get ext => this == OutputFormat.png ? 'png' : 'jpg';
  String get mimeType => this == OutputFormat.png ? 'image/png' : 'image/jpeg';
  String get label => this == OutputFormat.png ? 'PNG' : 'JPEG';
}

const videoExtensions = {
  '.mp4',
  '.m4v',
  '.mkv',
  '.mov',
  '.webm',
  '.3gp',
  '.3g2',
  '.ts',
  '.m2ts',
};

bool isVideoFile(String path) {
  final lastDot = path.lastIndexOf('.');
  if (lastDot == -1) return false;
  final ext = path.substring(lastDot).toLowerCase();
  return videoExtensions.contains(ext);
}
