// lib/features/lead/presentation/widgets/lead_detail_sheet/negociacion_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class NegociacionCard extends StatelessWidget {
  final Lead lead;
  final VoidCallback onEditarLead;
  final VoidCallback onGenerarSolicitud;

  const NegociacionCard({
    super.key,
    required this.lead,
    required this.onEditarLead,
    required this.onGenerarSolicitud,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zona superior: nombre+estado (izq) y datos del canal (der)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zona izquierda: ícono + evento + chip estado
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarCanal(idCanal: lead.idCanal),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            lead.evento,
                            style: AppTextStyles.labelMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          AppIconsSocial.chipEstado(
                            lead.idEstado,
                            label: lead.estado,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Zona derecha: filas de datos compactas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FilaDato(
                      icono: AppIconsSocial.widgetCanal(
                        lead.idCanal,
                        size: AppSizing.iconSm,
                      ),
                      etiqueta: 'Canal',
                      valor: lead.canal,
                      colorValor: AppIconsSocial.colorCanal(lead.idCanal),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    _FilaDato(
                      icono: const Icon(
                        AppIcons.moneda,
                        size: AppSizing.iconSm,
                        color: AppColors.textSecondary,
                      ),
                      etiqueta: 'Monto',
                      valor: 'S/ ${(lead.precioBase ?? 0.0).toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    _FilaDato(
                      icono: const Icon(
                        AppIcons.calendar,
                        size: AppSizing.iconSm,
                        color: AppColors.textSecondary,
                      ),
                      etiqueta: 'Actualizado',
                      valor: lead.fechaHora.formatDate(AppDateFormat.shortDate),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Botones compactos
          Row(
            children: [
              Expanded(
                child: CustomOutlinedButton(
                  text: 'Generar solicitud',
                  onPressed: onGenerarSolicitud,
                  height: AppSizing.buttonHeightSmall,
                  textStyle: AppTextStyles.buttonSmall,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  borderColor: AppColors.border,
                  borderWidth: AppSizing.hairline,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: CustomPrimaryButton(
                  text: 'Editar lead',
                  onPressed: onEditarLead,
                  height: AppSizing.buttonHeightSmall,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ícono circular del canal con fondo translúcido
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarCanal extends StatelessWidget {
  final int idCanal;
  const _AvatarCanal({required this.idCanal});

  @override
  Widget build(BuildContext context) {
    final colorCanal = AppIconsSocial.colorCanal(idCanal);
    return Container(
      width: AppSizing.avatarSm,
      height: AppSizing.avatarSm,
      decoration: BoxDecoration(
        color: colorCanal.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppIconsSocial.widgetCanal(
          idCanal,
          size: AppSizing.iconActionSm,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fila compacta: [ícono]  etiqueta  valor
// ─────────────────────────────────────────────────────────────────────────────

class _FilaDato extends StatelessWidget {
  final Widget icono;
  final String etiqueta;
  final String valor;
  final Color? colorValor;

  const _FilaDato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    this.colorValor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icono,
        const SizedBox(width: AppSpacing.xxs),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$etiqueta  ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                TextSpan(
                  text: valor,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorValor ?? AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
