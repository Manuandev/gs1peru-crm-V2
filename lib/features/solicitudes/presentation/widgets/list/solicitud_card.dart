// lib/features/solicitudes/presentation/widgets/list/solicitud_card.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback? onVer;
  final VoidCallback? onAccion;

  const SolicitudCard({
    super.key,
    required this.solicitud,
    this.onVer,
    this.onAccion,
  });

  // ── Color por estado ─────────────────────────────────────────────
  static Color colorEstado(String idEstado) => switch (idEstado) {
    '00' => AppColors.info,
    '01' => AppColors.warning,
    '02' => AppColors.success,
    '03' => AppColors.purple,
    _ => AppColors.textDisabled,
  };

  // ── Acción según estado: ninguna = solo "Ver" ─────────────────────
  static SolicitudAccionTipo _accion(String idEstado) => switch (idEstado) {
    '00' || '03' => SolicitudAccionTipo.cobranza, // "Completar"
    '01' => SolicitudAccionTipo.sinValidar, // "Validar"
    _ => SolicitudAccionTipo.ninguna,
  };

  @override
  Widget build(BuildContext context) {
    final accion = _accion(solicitud.idEstado);
    final canalInfo = CanalHelper.get(solicitud.idCanal);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
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
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Fila principal (Header) ────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: AppSizing.avatarRadiusMd,
                      backgroundColor: AvatarUtils.color(
                        solicitud.nombreCompleto,
                      ),
                      child: Text(
                        AvatarUtils.initials(solicitud.nombreCompleto),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: AppTextStyles.weightBold,
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    // Info del cliente
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            solicitud.nombreCompleto,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: AppTextStyles.weightBold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            solicitud.nombreEmpresa,
                            style: AppTextStyles.bodySmall.copyWith(
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
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _EstadoChip(
                          idEstado: solicitud.idEstado,
                          label: solicitud.estado,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

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
                                size: AppSizing.iconActionSm,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  solicitud.tipoSolicitud,
                                  style: AppTextStyles.bodySmall.copyWith(
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
                          // Canal de origen
                          Row(
                            children: [
                              Image.asset(
                                'assets/icons/whatsapp_logo.png',
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Origen: ${canalInfo.nombre}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
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
                    const SizedBox(width: AppSpacing.md),
                    // Columna Derecha: Ejecutivo responsable
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ejecutivo responsable',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                AppIcons.agent,
                                size: AppSizing.iconActionSm,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  solicitud.nombreAsesor,
                                  style: AppTextStyles.bodySmall.copyWith(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onVer,
                    icon: Icon(
                      AppIcons.visibility,
                      size: AppSizing.iconActionSm,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'Ver',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: const Size.fromHeight(
                        AppSizing.buttonHeightSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                      ),
                    ),
                  ),
                ),
                if (accion != SolicitudAccionTipo.ninguna) ...[
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: accion == SolicitudAccionTipo.cobranza
                        ? FilledButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              AppIcons.edit,
                              size: AppSizing.iconActionSm,
                            ),
                            label: const Text('Completar'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(
                                AppSizing.buttonHeightSmall,
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
                              size: AppSizing.iconActionSm,
                            ),
                            label: const Text('Validar'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(
                                AppSizing.buttonHeightSmall,
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
  final String idEstado;
  final String label;

  const _EstadoChip({required this.idEstado, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = SolicitudCard.colorEstado(idEstado);
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
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}
