// lib/features/solicitudes/presentation/widgets/detail/solicitud_detalle_widgets_base.dart
//
// Bloques base reutilizados por las secciones de SolicitudDetalleView
// (Datos del participante, Datos de facturación, Historial): la card
// genérica con ícono+título y la fila etiqueta/valor.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class SeccionCard extends StatelessWidget {
  final Color colorIcono;
  final IconData icono;
  final String titulo;
  final List<Widget> children;

  const SeccionCard({
    super.key,
    required this.colorIcono,
    required this.icono,
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorIcono.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icono,
                  color: colorIcono,
                  size: AppSizing.iconActionSm,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                titulo,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class FilaInfo extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final bool mostrarDivisor;

  const FilaInfo({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.mostrarDivisor = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  etiqueta,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  valor,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTextStyles.weightMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (mostrarDivisor)
          const Divider(color: AppColors.border, height: 1, thickness: 1),
      ],
    );
  }
}
