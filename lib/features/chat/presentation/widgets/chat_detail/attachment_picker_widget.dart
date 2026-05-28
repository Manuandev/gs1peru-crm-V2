// lib\features\chat\presentation\widgets\chat_detail\attachment_picker_widget.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/chat/presentation/widgets/chat_detail/staged_file.dart';

class AttachmentPickerWidget extends StatefulWidget {
  /// Callback con la lista completa de archivos staged al presionar "Enviar"
  final void Function(List<StagedFile> files) onFilesBatchPicked;
  final VoidCallback onClose;

  const AttachmentPickerWidget({
    super.key,
    required this.onFilesBatchPicked,
    required this.onClose,
  });

  @override
  State<AttachmentPickerWidget> createState() => _AttachmentPickerWidgetState();
}

class _AttachmentPickerWidgetState extends State<AttachmentPickerWidget> {
  static const _imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
  static const _videoExts = ['mp4', 'mov', 'avi', 'mkv', '3gp', 'webm'];
  static const _maxBytes = 16 * 1024 * 1024; // 16 MB

  final List<StagedFile> _staged = [];

  int get _totalBytes =>
      _staged.fold<int>(0, (sum, f) => sum + f.sizeBytes);

  double get _totalMB => _totalBytes / (1024 * 1024);

  double get _usageFraction => _totalBytes / _maxBytes;

  // ── Selección desde galería (multi: fotos + videos) ─────────────────────
  Future<void> _pickFromGallery() async {
    final files = await ImagePicker().pickMultipleMedia();
    if (files.isEmpty) return;

    final newStaged = <StagedFile>[];
    for (final xFile in files) {
      final file = File(xFile.path);
      final size = await file.length();
      final name = xFile.name;
      final dotIndex = name.lastIndexOf('.');
      final ext = dotIndex != -1 ? '.${name.substring(dotIndex + 1)}' : '';
      final nameWithoutExt =
          dotIndex != -1 ? name.substring(0, dotIndex) : name;
      final rawExt = ext.replaceFirst('.', '').toLowerCase();
      final tipo = _videoExts.contains(rawExt) ? 'video' : 'image';
      newStaged.add(StagedFile(
        path: xFile.path,
        nameWithoutExt: nameWithoutExt,
        ext: ext,
        tipo: tipo,
        sizeBytes: size,
      ));
    }

    _addFiles(newStaged);
  }

  // ── Selección desde cámara (single) ─────────────────────────────────────
  Future<void> _pickFromCamera() async {
    final xFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xFile == null) return;

    // Copiar a directorio de la app para garantizar acceso
    final dir = await getApplicationDocumentsDirectory();
    final newPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(xFile.path).copy(newPath);

    final size = await File(newPath).length();

    _addFiles([
      StagedFile(
        path: newPath,
        nameWithoutExt:
            DateTime.now().millisecondsSinceEpoch.toString(),
        ext: '.jpg',
        tipo: 'image',
        sizeBytes: size,
      ),
    ]);
  }

  // ── Selección de archivos (multi) ───────────────────────────────────────
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final newStaged = <StagedFile>[];
    for (final pFile in result.files) {
      if (pFile.path == null) continue;
      final ext = pFile.extension != null ? '.${pFile.extension}' : '';
      final nameWithoutExt = pFile.extension != null
          ? pFile.name.substring(0, pFile.name.lastIndexOf('.'))
          : pFile.name;
      final lowerExt = pFile.extension?.toLowerCase();
      final tipo = _imageExts.contains(lowerExt)
          ? 'image'
          : _videoExts.contains(lowerExt)
              ? 'video'
              : 'document';
      newStaged.add(StagedFile(
        path: pFile.path!,
        nameWithoutExt: nameWithoutExt,
        ext: ext,
        tipo: tipo,
        sizeBytes: pFile.size,
      ));
    }

    _addFiles(newStaged);
  }

  // ── Agregar archivos con validación de 16 MB ────────────────────────────
  void _addFiles(List<StagedFile> files) {
    final newTotal =
        _totalBytes + files.fold<int>(0, (sum, f) => sum + f.sizeBytes);
    if (newTotal > _maxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Los archivos seleccionados superan el límite de 16 MB '
              '(${(newTotal / (1024 * 1024)).toStringAsFixed(1)} MB)',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    setState(() => _staged.addAll(files));
  }

  // ── Quitar archivo individual ───────────────────────────────────────────
  void _removeFile(int index) {
    setState(() => _staged.removeAt(index));
  }

  // ── Enviar batch ────────────────────────────────────────────────────────
  void _sendBatch() {
    if (_staged.isEmpty) return;
    widget.onFilesBatchPicked(List.unmodifiable(_staged));
    setState(() => _staged.clear());
  }

  // ── Color de la barra de progreso según uso ─────────────────────────────
  Color _progressColor() {
    if (_usageFraction >= 0.9) return Colors.red;
    if (_usageFraction >= 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Botones de selección ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galería',
                  color: Colors.purple,
                  onTap: _pickFromGallery,
                ),
                _AttachOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Cámara',
                  color: Colors.blue,
                  onTap: _pickFromCamera,
                ),
                _AttachOption(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'Archivo',
                  color: Colors.orange,
                  onTap: _pickDocument,
                ),
                _AttachOption(
                  icon: Icons.close_rounded,
                  label: 'Cerrar',
                  color: Colors.grey,
                  onTap: widget.onClose,
                ),
              ],
            ),
          ),

          // ── Zona de staging (solo si hay archivos) ────────────────────
          if (_staged.isNotEmpty) ...[
            const Divider(height: 1),
            _buildStagingZone(colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildStagingZone(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Thumbnails / chips scrollable ──────────────────────────
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _staged.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final file = _staged[index];
                return _StagedFileChip(
                  file: file,
                  onRemove: () => _removeFile(index),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ── Barra de progreso ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _usageFraction.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: colorScheme.outlineVariant.withAlpha(80),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progressColor(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_totalMB.toStringAsFixed(1)} / 16.0 MB',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Botón enviar ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _sendBatch,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text('Enviar (${_staged.length})'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip visual de un archivo staged ──────────────────────────────────────────

class _StagedFileChip extends StatelessWidget {
  final StagedFile file;
  final VoidCallback onRemove;

  const _StagedFileChip({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isImage = file.tipo == 'image';

    return Stack(
      children: [
        Container(
          width: 72,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(120),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isImage
                ? Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                    width: 72,
                    height: 80,
                    errorBuilder: (_, _, _) => _buildDocIcon(colorScheme),
                  )
                : _buildDocIcon(colorScheme),
          ),
        ),
        // Botón ✕
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
        // Extensión / nombre
        if (!isImage)
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Text(
              file.ext.replaceFirst('.', '').toUpperCase(),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDocIcon(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.insert_drive_file_rounded,
        size: 32,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ── Opción individual del picker ──────────────────────────────────────────────

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
