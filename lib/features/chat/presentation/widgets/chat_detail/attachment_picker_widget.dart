// lib\features\chat\presentation\widgets\chat_detail\attachment_picker_widget.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

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

  int get _totalBytes => _staged.fold<int>(0, (sum, f) => sum + f.sizeBytes);

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
      final nameWithoutExt = dotIndex != -1
          ? name.substring(0, dotIndex)
          : name;
      final rawExt = ext.replaceFirst('.', '').toLowerCase();
      final tipo = _videoExts.contains(rawExt) ? 'video' : 'image';
      newStaged.add(
        StagedFile(
          path: xFile.path,
          nameWithoutExt: nameWithoutExt,
          ext: ext,
          tipo: tipo,
          sizeBytes: size,
        ),
      );
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
        nameWithoutExt: DateTime.now().millisecondsSinceEpoch.toString(),
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
      newStaged.add(
        StagedFile(
          path: pFile.path!,
          nameWithoutExt: nameWithoutExt,
          ext: ext,
          tipo: tipo,
          sizeBytes: pFile.size,
        ),
      );
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
            backgroundColor: AppColors.errorDark,
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
    if (_usageFraction >= 0.9) return AppColors.error;
    if (_usageFraction >= 0.7) return AppColors.warning;
    return AppColors.success;
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachOption(
                  icon: AppIcons.photoLibrary,
                  label: 'Galería',
                  color: AppColors.attachGallery,
                  onTap: _pickFromGallery,
                ),
                _AttachOption(
                  icon: AppIcons.camera,
                  label: 'Cámara',
                  color: AppColors.info,
                  onTap: _pickFromCamera,
                ),
                _AttachOption(
                  icon: AppIcons.fileGeneric,
                  label: 'Archivo',
                  color: AppColors.warning,
                  onTap: _pickDocument,
                ),
                _AttachOption(
                  icon: AppIcons.close,
                  label: 'Cerrar',
                  color: AppColors.grey500,
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm2,
        AppSpacing.sm,
        AppSpacing.sm2,
        AppSpacing.sm2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Thumbnails / chips scrollable ──────────────────────────
          SizedBox(
            height: AppSizing.attachThumbnailHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _staged.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final file = _staged[index];
                return _StagedFileChip(
                  file: file,
                  onRemove: () => _removeFile(index),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.smPlus),

          // ── Barra de progreso ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizing.radiusXs),
                  child: LinearProgressIndicator(
                    value: _usageFraction.clamp(0.0, 1.0),
                    minHeight: AppSizing.progressBarHeight,
                    backgroundColor: colorScheme.outlineVariant.withAlpha(80),
                    valueColor: AlwaysStoppedAnimation<Color>(_progressColor()),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.smPlus),
              Text(
                '${_totalMB.toStringAsFixed(1)} / 16.0 MB',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: AppTextStyles.weightSemiBold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.smPlus),

          // ── Botón enviar ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _sendBatch,
              icon: const Icon(AppIcons.send, size: AppSizing.iconActionSm),
              label: Text('Enviar (${_staged.length})'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
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
          width: AppSizing.avatarXl,
          height: AppSizing.attachThumbnailHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizing.radiusSm2),
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(120),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizing.radiusSm2),
            child: isImage
                ? Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                    width: AppSizing.avatarXl,
                    height: AppSizing.attachThumbnailHeight,
                    errorBuilder: (_, _, _) => _buildDocIcon(colorScheme),
                  )
                : _buildDocIcon(colorScheme),
          ),
        ),
        // Botón ✕
        Positioned(
          top: AppSpacing.xxs,
          right: AppSpacing.xxs,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: AppSizing.iconSearch,
              height: AppSizing.iconSearch,
              decoration: BoxDecoration(
                color: AppColors.black(0.54),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.close,
                size: AppSizing.iconXs,
                color: AppColors.textOnDark,
              ),
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
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: AppTextStyles.sizeXxs,
                fontWeight: AppTextStyles.weightBold,
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
        AppIcons.fileGeneric,
        size: AppSizing.iconLg,
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
            width: AppSizing.videoPlayButton,
            height: AppSizing.videoPlayButton,
            decoration: BoxDecoration(
              color: color.withValues(alpha: AppColors.opacityDisabledBg),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: AppSizing.iconMd),
          ),
          const SizedBox(height: AppSpacing.chipGap),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
