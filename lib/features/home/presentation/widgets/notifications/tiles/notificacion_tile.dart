// lib/features/home/presentation/widgets/notifications/tiles/notificacion_tile.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificacionTile extends StatelessWidget {
  final Notificacion notificacion;
  final VoidCallback? onAccion;

  const NotificacionTile({
    super.key,
    required this.notificacion,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (iconoColor, icono) = _resolverIcono();
    // Mensaje/derivación necesitan idChatCab para navegar — si el dato no
    // llegó (notificación vieja o sin chat asociado), no se muestra el botón.
    // Actividad/Recordatorio/Por contactar/Reasignado todavía no tienen su
    // propio id de destino, así que por ahora siempre se muestran (igual que
    // en el mockup).
    final mostrarBoton =
        notificacion.tipo == TipoNotificacion.actividad ||
        notificacion.tipo == TipoNotificacion.recordatorio ||
        notificacion.tipo == TipoNotificacion.leadPorContactar ||
        notificacion.tipo == TipoNotificacion.leadReasignado ||
        notificacion.idChatCab != null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Indicador de no leído ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.xs,
              right: AppSpacing.xxs,
            ),
            child: Container(
              width: AppSizing.dotIndicatorSize,
              height: AppSizing.dotIndicatorSize,
              decoration: BoxDecoration(
                color: notificacion.leido ? Colors.transparent : AppColors.info,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ── Ícono con fondo coloreado ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: iconoColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusSm2),
            ),
            child: Icon(icono, size: AppSizing.iconActionSm, color: iconoColor),
          ),

          const SizedBox(width: AppSpacing.xs),

          // ── Contenido ───────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notificacion.titulo,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      notificacion.fechaHora.formatHora12(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colorScheme.onSurface.withValues(
                          alpha: AppColors.opacityHint,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  notificacion.descripcion,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppColors.opacityTextMuted,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    _ChipTipo(
                      label: notificacion.etiquetaPrincipal,
                      color: _colorTipo(),
                    ),
                    if (notificacion.mostrarChipNuevo)
                      const _ChipTipo(label: 'Nuevo', color: AppColors.success),
                  ],
                ),
              ],
            ),
          ),

          if (mostrarBoton) ...[
            const SizedBox(width: AppSpacing.xs),

            // ── Botón de acción ───────────────────────────────────────────
            SizedBox(
              width: 96,
              child: OutlinedButton(
                onPressed: onAccion,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  notificacion.labelAccion,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.primary,
                    fontWeight: AppTextStyles.weightMedium,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Por el momento un ícono único por tipo — sin distinción de subtipo
  (Color, IconData) _resolverIcono() => switch (notificacion.tipo) {
    TipoNotificacion.actividad => (
      AppColors.secondary,
      AppIcons.actividadNotificacion,
    ),
    TipoNotificacion.derivacion => (
      AppColors.brandLavenderAccessible,
      AppIcons.ia,
    ),
    TipoNotificacion.mensaje => (
      AppColors.brandSlateAccessible,
      AppIcons.chatDots,
    ),
    TipoNotificacion.recordatorio => (AppColors.warning, AppIcons.time),
    TipoNotificacion.leadPorContactar => (AppColors.info, AppIcons.phone),
    TipoNotificacion.leadReasignado => (
      AppColors.brandRaspberryAccessible,
      AppIcons.reasignar,
    ),
  };

  Color _colorTipo() => switch (notificacion.tipo) {
    TipoNotificacion.actividad => AppColors.secondary,
    TipoNotificacion.derivacion => AppColors.brandLavenderAccessible,
    TipoNotificacion.mensaje => AppColors.brandSlateAccessible,
    TipoNotificacion.recordatorio => AppColors.warning,
    TipoNotificacion.leadPorContactar => AppColors.info,
    TipoNotificacion.leadReasignado => AppColors.brandRaspberryAccessible,
  };
}

class _ChipTipo extends StatelessWidget {
  final String label;
  final Color color;

  const _ChipTipo({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: AppTextStyles.weightMedium,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
