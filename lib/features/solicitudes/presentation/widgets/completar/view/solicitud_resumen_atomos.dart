// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_resumen_atomos.dart
//
// Bloques base reutilizados por las secciones de SolicitudResumenView
// (cabecera con ícono+título+acción, campo de dato, botón "Editar" y fila
// de dos campos lado a lado).

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class CabeceraSeccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Widget? accion;

  const CabeceraSeccion({
    super.key,
    required this.icono,
    required this.titulo,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: AppColors.primary, size: AppSizing.iconMd),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            titulo,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: AppTextStyles.weightBold,
            ),
          ),
        ),
        if (accion != null) accion!,
      ],
    );
  }
}

class CampoDato extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const CampoDato({
    super.key,
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icono,
            size: AppSizing.iconActionSm,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                valor,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BotonEditar extends StatelessWidget {
  final VoidCallback onTap;

  const BotonEditar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CustomOutlinedButton(
      text: 'Editar',
      icon: AppIcons.edit,
      onPressed: onTap,
      compacto: true,
      iconSize: AppSizing.iconXxs,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      borderRadius: AppSizing.radiusSm,
      foregroundColor: AppColors.primary,
      borderColor: AppColors.primary,
      textStyle: AppTextStyles.labelSmall.copyWith(
        fontWeight: AppTextStyles.weightMedium,
      ),
    );
  }
}

class FilaCampos extends StatelessWidget {
  final Widget izquierdo;
  final Widget derecho;

  const FilaCampos({super.key, required this.izquierdo, required this.derecho});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: izquierdo),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: derecho),
      ],
    );
  }
}
