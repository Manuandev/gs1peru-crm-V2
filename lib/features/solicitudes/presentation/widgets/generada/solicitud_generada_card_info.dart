// lib/features/solicitudes/presentation/widgets/generada/solicitud_generada_card_info.dart
//
// Card con avatar, nombre/empresa, oportunidad, condición (estado), tipo de
// comprobante y ejecutivo asignado, usada por SolicitudGeneradaView.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class CardInfoSolicitud extends StatelessWidget {
  final Solicitud solicitud;
  final String comprobante;

  const CardInfoSolicitud({
    super.key,
    required this.solicitud,
    this.comprobante = '',
  });

  @override
  Widget build(BuildContext context) {
    final colorEstado = SolicitudCard.colorEstado(solicitud.ibValidado);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Cabecera: avatar + nombre + empresa ───────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: AppSizing.avatarRadiusMd,
                  backgroundColor: AvatarUtils.color(solicitud.nombreCompleto),
                  child: Text(
                    AvatarUtils.initials(solicitud.nombreCompleto),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: AppTextStyles.weightBold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        solicitud.nombreCompleto,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: AppTextStyles.weightBold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        solicitud.nombreEmpresa,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.8),

          // ── Cuerpo: info izquierda + divider + ejecutivo derecha
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda — 3 filas
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FilaInfoCard(
                          icono: AppIcons.receipt,
                          label: 'N° de Solicitud',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizing.radiusCircular,
                              ),
                            ),
                            child: Text(
                              solicitud.idSolicitud.isEmpty
                                  ? '—'
                                  : solicitud.idSolicitud,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: AppTextStyles.weightBold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _FilaInfoCard(
                          icono: AppIcons.listAlt,
                          label: 'Oportunidad / Curso',
                          child: Text(
                            solicitud.oportunidad,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: AppTextStyles.weightRegular,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _FilaInfoCard(
                          icono: AppIcons.checkCircle,
                          label: 'Condición',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: colorEstado.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizing.radiusCircular,
                              ),
                            ),
                            child: Text(
                              solicitud.estado,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: colorEstado,
                                fontWeight: AppTextStyles.weightSemiBold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _FilaInfoCard(
                          icono: AppIcons.fileFactura,
                          label: 'Tipo de comprobante',
                          child: Text(
                            comprobante.isEmpty ? '—' : comprobante,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: AppTextStyles.weightRegular,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(width: 1, color: AppColors.border),

                // Columna derecha — ejecutivo + origen
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ejecutivo',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: AvatarUtils.color(
                                solicitud.nombreAsesor,
                              ),
                              child: Text(
                                AvatarUtils.initials(solicitud.nombreAsesor),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: AppColors.textOnDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                solicitud.nombreAsesor,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: AppTextStyles.weightSemiBold,
                                  fontSize: 10,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaInfoCard extends StatelessWidget {
  final IconData icono;
  final String label;
  final Widget child;

  const _FilaInfoCard({
    required this.icono,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Label arriba (con ícono) y valor debajo, en vez de lado a lado — con
    // un valor lado a lado no había espacio suficiente y se desbordaba
    // (ej. "Oportunidad / Curso" con nombres largos). Apilado + elipsis en
    // el valor evita el overflow sin importar qué tan largo sea el texto.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        child,
      ],
    );
  }
}
