// lib/features/lead/presentation/widgets/detalle/lead_detalle_info_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetalleInfoCard extends StatelessWidget {
  final LeadDetalleCompleto detalle;
  const LeadDetalleInfoCard({super.key, required this.detalle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoFila(
            icono: AppIconsSocial.widgetCanal(detalle.idCanal, size: AppSizing.iconSm),
            etiqueta: 'Origen',
            valor: detalle.canal,
          ),
          const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
          _InfoFila(
            icono: Icon(AppIcons.interes, size: AppSizing.iconSm, color: AppColors.textSecondary),
            etiqueta: 'Curso / Interés',
            valor: detalle.interes ?? 'Sin interés',
          ),
          const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
          _InfoFila(
            icono: Icon(AppIcons.business, size: AppSizing.iconSm, color: AppColors.textSecondary),
            etiqueta: 'Empresa',
            valor: detalle.nombreEmpresa.isEmpty ? 'Sin empresa' : detalle.nombreEmpresa,
          ),
          const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
          _InfoFila(
            icono: Icon(AppIcons.phone, size: AppSizing.iconSm, color: AppColors.textSecondary),
            etiqueta: 'Teléfono',
            valor: detalle.telefono,
          ),
          const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
          _InfoFila(
            icono: Icon(AppIcons.email, size: AppSizing.iconSm, color: AppColors.textSecondary),
            etiqueta: 'Correo',
            valor: detalle.correo,
          ),
        ],
      ),
    );
  }
}

class _InfoFila extends StatelessWidget {
  final Widget icono;
  final String etiqueta;
  final String valor;

  const _InfoFila({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(width: 20, child: icono),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 96,
            child: Text(
              etiqueta,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(valor, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    );
  }
}
