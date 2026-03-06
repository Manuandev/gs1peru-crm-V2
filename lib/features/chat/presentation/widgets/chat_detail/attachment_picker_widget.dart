// lib\features\chat\presentation\widgets\chat_detail\attachment_picker_widget.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AttachmentPickerWidget extends StatelessWidget {
  /// path, nombre, ext, tipo ('image' | 'document')
  final void Function(String path, String name, String ext, String tipo)
  onFilePicked;
  final VoidCallback onClose;

  const AttachmentPickerWidget({
    super.key,
    required this.onFilePicked,
    required this.onClose,
  });

  static const _imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AttachOption(
            icon: Icons.photo_library_rounded,
            label: 'Galería',
            color: Colors.purple,
            onTap: () => _pickFromGallery(context),
          ),
          _AttachOption(
            icon: Icons.camera_alt_rounded,
            label: 'Cámara',
            color: Colors.blue,
            onTap: () => _pickFromCamera(context),
          ),
          _AttachOption(
            icon: Icons.insert_drive_file_rounded,
            label: 'Archivo',
            color: Colors.orange,
            onTap: () => _pickDocument(context),
          ),
          _AttachOption(
            icon: Icons.close_rounded,
            label: 'Cerrar',
            color: Colors.grey,
            onTap: onClose,
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    _handleImageFile(file);
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85, // ← comprimir un poco
    );
    if (file == null) return;

    // Copiar a directorio de la app para garantizar acceso
    final dir = await getApplicationDocumentsDirectory();
    final newPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(file.path).copy(newPath);

    _handleImageFile(XFile(newPath));
  }

  void _handleImageFile(XFile file) {
    final name = file.name;
    final dotIndex = name.lastIndexOf('.');
    final ext = dotIndex != -1 ? '.${name.substring(dotIndex + 1)}' : '';
    final nameWithoutExt = dotIndex != -1 ? name.substring(0, dotIndex) : name;
    onFilePicked(file.path, nameWithoutExt, ext, 'image');
  }

  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) return;

    final ext = file.extension != null ? '.${file.extension}' : '';
    final nameWithoutExt = file.extension != null
        ? file.name.substring(0, file.name.lastIndexOf('.'))
        : file.name;

    final tipo = _imageExts.contains(file.extension?.toLowerCase())
        ? 'image'
        : 'document';

    onFilePicked(file.path!, nameWithoutExt, ext, tipo);
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
