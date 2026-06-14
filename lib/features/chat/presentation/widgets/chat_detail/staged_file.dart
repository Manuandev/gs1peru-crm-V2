// lib/features/chat/presentation/widgets/chat_detail/staged_file.dart

/// Representa un archivo en la zona de staging antes de enviarlo.
class StagedFile {
  final String path;
  final String nameWithoutExt; // e.g. "1000460561"
  final String ext; // e.g. ".jpg"
  final String tipo; // 'image' | 'document'
  final int sizeBytes;

  const StagedFile({
    required this.path,
    required this.nameWithoutExt,
    required this.ext,
    required this.tipo,
    required this.sizeBytes,
  });
}
