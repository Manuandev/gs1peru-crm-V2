// lib/features/solicitudes/presentation/widgets/completar/solicitud_chips_canales.dart
//
// Chips de canal ("¿Cómo se enteró del evento?") — catálogo real vía
// CatalogsBloc, selección única.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class ChipsCanales extends StatelessWidget {
  final List<CanalExpoItem> canales;
  final CanalExpoItem? seleccionado;
  final bool habilitado;
  final ValueChanged<CanalExpoItem> onSeleccionar;

  const ChipsCanales({
    super.key,
    required this.canales,
    required this.seleccionado,
    required this.habilitado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    if (canales.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: canales.map((canal) {
        final activo = seleccionado?.id == canal.id;
        final colorTexto = activo
            ? AppColors.primary
            : (habilitado ? AppColors.textSecondary : AppColors.textDisabled);

        return GestureDetector(
          onTap: habilitado ? () => onSeleccionar(canal) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: activo
                  ? AppColors.primaryWithOpacity(0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              border: Border.all(
                color: activo ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSocialUtils.widgetCanalById(
                  canal.id,
                  size: AppSizing.iconActionSm,
                ),
                const SizedBox(width: AppSpacing.sm2),
                Text(
                  canal.descripcion,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorTexto,
                    fontWeight: activo
                        ? AppTextStyles.weightSemiBold
                        : AppTextStyles.weightRegular,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
