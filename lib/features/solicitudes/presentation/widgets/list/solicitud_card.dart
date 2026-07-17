// lib/features/solicitudes/presentation/widgets/list/solicitud_card.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback? onVer;
  final VoidCallback? onAccion;
  final bool mostrarBotones;

  const SolicitudCard({
    super.key,
    required this.solicitud,
    this.onVer,
    this.onAccion,
    this.mostrarBotones = true,
  });

  // ── Color por estado ─────────────────────────────────────────────
  static Color colorEstado(bool validado) =>
      validado ? AppColors.success : AppColors.warning;

  // ── Acción según validación + estado ──────────────────────────────
  // 1. Sin validar y aún "Por Completar" (ibValidado == false && idEstado
  //    == 0) → "Validar".
  // 2. Validada y con estado > 0 (ya avanzó más allá de "Por Completar")
  //    → ninguna acción, solo "Ver": ya no hay nada que completar.
  // 3. Validada y con estado == 0 (aún "Por Completar") → "Completar":
  //    en el detalle podrá elegir "Editar ficha" o "Continuar" (ver
  //    Solicitud.puedeEditar, que solo mira idEstado == 0).
  // El caso restante (sin validar y estado > 0) no está definido por
  // negocio todavía — cae a "ninguna" (solo "Ver"), el default más
  // conservador, igual que antes de esta regla.
  static SolicitudAccionTipo _accion(bool ibValidado, int idEstado) {
    if (!ibValidado && idEstado == 0) return SolicitudAccionTipo.sinValidar;
    if (ibValidado && idEstado == 0) return SolicitudAccionTipo.cobranza;
    return SolicitudAccionTipo.ninguna;
  }

  @override
  Widget build(BuildContext context) {
    final accion = _accion(solicitud.ibValidado, solicitud.idEstado);
    // final canalInfo = CanalHelper.get(solicitud.idCanal);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppSizing.shadowBlurXs,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Cuerpo ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Fila principal (Header) ────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar — solo ícono de persona sobre círculo de color,
                    // mismo estilo compacto que LeadCard (sin iniciales)
                    CircleAvatar(
                      radius: AppSizing.avatarRadiusSm,
                      backgroundColor: AvatarUtils.color(
                        solicitud.nombreCompleto,
                      ),
                      child: Icon(
                        AppIcons.user,
                        size: AppSizing.iconSm,
                        color: AppColors.textOnDark,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    // Info del cliente
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            solicitud.nombreCompleto,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: AppTextStyles.weightSemiBold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            solicitud.nombreEmpresa,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    // Fecha + Estado
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          solicitud.fechaCreacion.formatWhatsApp(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _EstadoChip(validado: solicitud.ibValidado),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Información en Grid (2 columnas) ───────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Columna Izquierda: Tipo de solicitud y Origen
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tipo de solicitud
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: AppSizing.iconSm,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  solicitud.oportunidad,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: AppTextStyles.weightMedium,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Num. Solicitud: ${solicitud.idSolicitud}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Canal de origen — ícono real del canal (antes
                          // quedó hardcodeado al ícono de WhatsApp sin
                          // importar el canal real de la solicitud)
                          // Row(
                          //   children: [
                          //     CanalHelper.icon(
                          //       solicitud.idCanal,
                          //       size: AppSizing.iconSm,
                          //     ),
                          //     const SizedBox(width: AppSpacing.xs),
                          //     Expanded(
                          //       child: Text(
                          //         'Canal: ${canalInfo.nombre}',
                          //         style: AppTextStyles.labelSmall.copyWith(
                          //           color: AppColors.textSecondary,
                          //         ),
                          //         maxLines: 1,
                          //         overflow: TextOverflow.ellipsis,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Columna Derecha: Ejecutivo responsable
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ejecutivo',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                AppIcons.user,
                                size: AppSizing.iconSm,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  solicitud.nombreAsesor,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: AppTextStyles.weightMedium,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Botones ───────────────────────────────────────────────
          if (mostrarBotones)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                0,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onVer,
                      icon: Icon(
                        AppIcons.visibility,
                        size: AppSizing.iconSm,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'Ver',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: AppTextStyles.weightSemiBold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: const Size.fromHeight(
                          AppSizing.buttonHeightCompact,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizing.radiusMd,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (accion != SolicitudAccionTipo.ninguna) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: accion == SolicitudAccionTipo.cobranza
                          ? FilledButton.icon(
                              onPressed: onAccion,
                              icon: Icon(AppIcons.edit, size: AppSizing.iconSm),
                              label: Text(
                                'Completar',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: AppTextStyles.weightSemiBold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(
                                  AppSizing.buttonHeightCompact,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizing.radiusMd,
                                  ),
                                ),
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: onAccion ?? () {},
                              icon: Icon(
                                AppIcons.checkCircle,
                                size: AppSizing.iconSm,
                              ),
                              label: Text(
                                'Validar',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: AppTextStyles.weightSemiBold,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(
                                  AppSizing.buttonHeightCompact,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizing.radiusMd,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Chip de estado coloreado ─────────────────────────────────────────────────

class _EstadoChip extends StatelessWidget {
  final bool validado;

  const _EstadoChip({required this.validado});

  @override
  Widget build(BuildContext context) {
    final color = SolicitudCard.colorEstado(validado);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
      ),
      child: Text(
        validado ? 'Validado' : 'Sin validar',
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}
