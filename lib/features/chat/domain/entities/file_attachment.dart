// lib\features\chat\domain\entities\file_attachment.dart

// lib/features/chat/domain/entities/file_attachment.dart
//
// PROPÓSITO:
//   Entidad de dominio que representa un archivo adjunto en el chat.
//   Es independiente de cualquier paquete de Flutter o de infraestructura.
//
// ¿POR QUÉ EXISTE?
//   La capa de dominio no puede depender de `file_picker` (infraestructura).
//   Cuando el usuario selecciona archivos en la UI, se convierten a esta
//   entidad antes de entrar al dominio.
//
//   UI (PlatformFile) → FileAttachment → Domain/Data
//
// USO:
//   // En la view, convertir PlatformFile → FileAttachment
//   final attachment = FileAttachment.fromPlatformFile(file);
//
//   // En el evento del BLoC
//   ChatDetailFilesSelected(files: [attachment])

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

class FileAttachment extends Equatable {
  /// Ruta absoluta local del archivo en el dispositivo
  final String path;

  /// Nombre completo del archivo con extensión (ej: "contrato.pdf")
  final String name;

  /// Extensión sin punto en minúsculas (ej: "pdf", "jpg").
  /// Null si el archivo no tiene extensión.
  final String? extension;

  /// Tamaño del archivo en bytes
  final int size;

  const FileAttachment({
    required this.path,
    required this.name,
    this.extension,
    required this.size,
  });

  // ============================================================
  // FACTORY DESDE PLATAFORMA
  // ============================================================

  /// Convierte un [PlatformFile] (file_picker) a [FileAttachment].
  ///
  /// Lanza [ArgumentError] si el archivo no tiene ruta local
  /// (puede pasar en web o si allowCompression está activo).
  factory FileAttachment.fromPlatformFile(PlatformFile file) {
    if (file.path == null) {
      throw ArgumentError(
        'PlatformFile sin ruta local: ${file.name}. '
        'Asegurate de usar FilePicker con allowCompression: false en iOS.',
      );
    }

    return FileAttachment(
      path: file.path!,
      name: file.name,
      extension: file.extension?.toLowerCase(),
      size: file.size,
    );
  }

  // ============================================================
  // GETTERS UTILITARIOS
  // ============================================================

  /// Nombre del archivo SIN extensión (ej: "contrato")
  String get nameWithoutExtension {
    final dot = name.lastIndexOf('.');
    return dot != -1 ? name.substring(0, dot) : name;
  }

  /// Extensión con punto incluido (ej: ".pdf").
  /// Retorna cadena vacía si no tiene extensión.
  String get extensionWithDot {
    if (extension == null || extension!.isEmpty) return '';
    return '.$extension';
  }

  /// ¿Es imagen? (jpg, jpeg, png, gif, bmp, webp)
  bool get isImage =>
      const {'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'}.contains(extension);

  /// ¿Es audio? (aac, mp3, ogg, m4a, opus)
  bool get isAudio =>
      const {'aac', 'mp3', 'ogg', 'm4a', 'opus'}.contains(extension);

  /// ¿Es video? (mp4, mov, avi, mkv, webm)
  bool get isVideo =>
      const {'mp4', 'mov', 'avi', 'mkv', 'webm'}.contains(extension);

  /// ¿Es documento? (pdf, doc, docx, xls, xlsx, etc.)
  bool get isDocument => !isImage && !isAudio && !isVideo;

  /// Tamaño formateado legible (ej: "2.4 MB", "340 KB")
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ============================================================
  // EQUATABLE
  // ============================================================

  @override
  List<Object?> get props => [path, name, extension, size];

  @override
  String toString() =>
      'FileAttachment(name: $name, ext: $extension, size: $formattedSize)';
}