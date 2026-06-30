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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Indicador de no leído ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, right: AppSpacing.xs),
            child: Container(
              width: AppSizing.dotIndicatorSize,
              height: AppSizing.dotIndicatorSize,
              decoration: BoxDecoration(
                color: notificacion.leido
                    ? Colors.transparent
                    : AppColors.info,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ── Ícono con fondo coloreado ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconoColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            ),
            child: Icon(icono, size: AppSizing.iconMd, color: iconoColor),
          ),

          const SizedBox(width: AppSpacing.sm),

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
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      notificacion.fechaHora.formatSinHoy(),
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
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurface.withValues(
                      alpha: AppColors.opacityTextMuted,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    _ChipTipo(
                      label: notificacion.etiquetaPrincipal,
                      color: _colorTipo(),
                    ),
                    if (notificacion.mostrarChipNuevo)
                      const _ChipTipo(
                        label: 'Nuevo',
                        color: AppColors.success,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // ── Botón de acción ─────────────────────────────────────────────
          SizedBox(
            width: 90,
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
      ),
    );
  }

  (Color, IconData) _resolverIcono() => switch (notificacion.subtipo) {
    SubtipoNotificacion.llamada            => (AppColors.warning,                  AppIcons.phone),
    SubtipoNotificacion.correo             => (AppColors.warning,                  AppIcons.email),
    SubtipoNotificacion.whatsappActividad  => (AppColors.warning,                  AppIcons.chat),
    SubtipoNotificacion.actividadGenerica  => (AppColors.warning,                  AppIcons.notificationActive),
    SubtipoNotificacion.leadBot            => (AppColors.brandLavenderAccessible,  AppIcons.ia),
    SubtipoNotificacion.prospectoDerivado  => (AppColors.brandLavenderAccessible,  AppIcons.leadNuevo),
    SubtipoNotificacion.derivacionGenerica => (AppColors.brandLavenderAccessible,  AppIcons.reasignar),
    SubtipoNotificacion.mensajeWhatsapp    => (AppColors.brandForest,              AppIcons.chat),
    SubtipoNotificacion.mensajeChat        => (AppColors.brandSlateAccessible,     AppIcons.chatDots),
  };

  Color _colorTipo() => switch (notificacion.tipo) {
    TipoNotificacion.actividad  => AppColors.warning,
    TipoNotificacion.derivacion => AppColors.brandLavenderAccessible,
    TipoNotificacion.mensaje    => AppColors.brandSlateAccessible,
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
      ),
    );
  }
}
