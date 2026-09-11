// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_participantes_botones.dart
//
// Botones pequeños del encabezado de SolicitudParticipantesView: solo-ícono
// ("Nuevo"/"Eliminar todos") e ícono+texto ("Carga masiva"). Ambos son
// CustomOutlinedButton en modo `compacto` (se ajustan a su contenido).

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class BotonIconoSmall extends StatelessWidget {
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const BotonIconoSmall({
    super.key,
    required this.icono,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorEfectivo = enabled ? color : AppColors.textDisabled;
    return CustomOutlinedButton(
      text: '',
      icon: icono,
      onPressed: onTap,
      isEnabled: enabled,
      compacto: true,
      iconSize: AppSizing.iconXs,
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderRadius: AppSizing.radiusSm,
      foregroundColor: colorEfectivo,
      borderColor: colorEfectivo,
    );
  }
}

class BotonSeccionSmall extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const BotonSeccionSmall({
    super.key,
    required this.icono,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.primary : AppColors.textDisabled;
    return CustomOutlinedButton(
      text: label,
      icon: icono,
      onPressed: onTap,
      isEnabled: enabled,
      compacto: true,
      iconSize: AppSizing.iconXs,
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderRadius: AppSizing.radiusSm,
      foregroundColor: color,
      borderColor: color,
      textStyle: AppTextStyles.labelSmall.copyWith(
        fontWeight: AppTextStyles.weightSemiBold,
      ),
    );
  }
}
