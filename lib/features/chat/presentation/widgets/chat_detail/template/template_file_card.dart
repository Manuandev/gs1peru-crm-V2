// lib/features/chat/presentation/widgets/chat_detail/template/template_file_card.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

/// Card de archivo adjunto de una plantilla — ícono + color por extensión
/// (centralizado en `file_type_utils.dart`), nombre y extensión.
///
/// Reemplaza el chip chico de una sola línea que tenía antes el selector de
/// plantillas (`_ArchivoChip`) — el jefe pidió una versión más grande con
/// más info (nombre + extensión bien visibles). Se usa tanto en
/// `select_template_modal.dart` (lista y vista previa) como en el formulario
/// de crear/editar plantilla.
///
/// `compact: true` da una versión chica en fila (ícono + "nombre.ext" en una
/// línea) — pensada para espacios angostos como la lista lateral de 172px
/// del selector.
///
/// `detailed: true` da una versión en fila más grande (ícono + nombre en
/// negrita + "EXT · peso" debajo, botón de quitar como ícono simple a la
/// derecha) — usada en la sección de adjuntos del formulario de plantilla,
/// donde además del nombre/extensión importa mostrar el peso del archivo
/// (`sizeBytes`, viene de `StagedFile`).
class TemplateFileCard extends StatelessWidget {
  final String nombre;
  final String ext;
  final bool compact;
  final bool detailed;
  final int sizeBytes;
  final double size;
  final VoidCallback? onRemove;

  const TemplateFileCard({
    super.key,
    required this.nombre,
    required this.ext,
    this.compact = false,
    this.detailed = false,
    this.sizeBytes = 0,
    this.size = AppSizing.fileCardSize,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final archivo = nombreArchivoConExtension(nombre, ext);
    final colorScheme = Theme.of(context).colorScheme;
    final color = fileColor(archivo);
    final icon = fileIcon(archivo);

    if (detailed) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm2),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: AppSizing.hairline,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizing.iconContainerMd,
              height: AppSizing.iconContainerMd,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSizing.radiusSm2),
              ),
              child: Icon(icon, size: AppSizing.iconMd, color: AppColors.textOnDark),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    archivo,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${ext.replaceFirst('.', '').toUpperCase()} · ${formatFileSize(sizeBytes)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              GestureDetector(
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  child: Icon(
                    AppIcons.close,
                    size: AppSizing.iconActionSm,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: AppSizing.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizing.iconSm, color: color),
            const SizedBox(width: AppSpacing.xxs),
            Flexible(
              child: Text(
                archivo,
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: size,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: AppSizing.hairline,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizing.iconContainerMd,
                height: AppSizing.iconContainerMd,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppSizing.radiusSm2),
                ),
                child: Icon(icon, size: AppSizing.iconMd, color: AppColors.textOnDark),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                nombre,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: AppTextStyles.weightSemiBold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                ext.replaceFirst('.', '').toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (onRemove != null)
            Positioned(
              top: -AppSpacing.xs,
              right: -AppSpacing.xs,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.close,
                    size: AppSizing.iconSm,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
