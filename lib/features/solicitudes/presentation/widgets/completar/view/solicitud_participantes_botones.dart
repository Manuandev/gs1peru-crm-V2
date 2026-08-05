// lib/features/solicitudes/presentation/widgets/completar/view/solicitud_participantes_botones.dart
//
// Botones pequeños del encabezado de SolicitudParticipantesView: solo-ícono
// ("Nuevo"/"Eliminar todos") e ícono+texto ("Carga masiva").

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
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorEfectivo,
        side: BorderSide(color: colorEfectivo),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
      ),
      child: Icon(icono, size: 14),
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
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icono, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
        textStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: AppTextStyles.weightSemiBold,
        ),
      ),
    );
  }
}
