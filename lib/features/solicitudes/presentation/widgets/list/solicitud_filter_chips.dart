// lib/features/solicitudes/presentation/widgets/list/solicitud_filter_chips.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

/// Chips de filtro de la lista de Solicitudes. El chip "Asesores" solo se
/// muestra si `SessionService().isModerador` — mismo patrón que
/// `CobranzaFilterChips`.
class SolicitudFilterChips extends StatelessWidget {
  final SolicitudFiltro filtroActual;
  final void Function(SolicitudFiltro) onFiltroTap;

  const SolicitudFilterChips({
    super.key,
    required this.filtroActual,
    required this.onFiltroTap,
  });

  static const _chipsBase = [
    (filtro: SolicitudFiltro.todas, label: 'Todas'),
    (filtro: SolicitudFiltro.asesores, label: 'Asesores'),
    (filtro: SolicitudFiltro.sinValidar, label: 'Sin validar'),
    (filtro: SolicitudFiltro.enviarACobranza, label: 'Validados'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isModerador = SessionService().isModerador;
    final chips = isModerador
        ? _chipsBase
        : _chipsBase.where((c) => c.filtro != SolicitudFiltro.asesores);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: chips.map((chip) {
            final isSelected = filtroActual == chip.filtro;

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => onFiltroTap(chip.filtro),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.chipPaddingH,
                    vertical: AppSpacing.chipPaddingV,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSizing.radiusXl),
                    boxShadow: isSelected
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.black(0.08),
                              blurRadius: AppSizing.shadowBlurSm,
                              offset: const Offset(0, 2),
                            ),
                          ],
                    border: isSelected
                        ? null
                        : Border.all(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                            width: AppSizing.borderWidthThin,
                          ),
                  ),
                  child: Text(
                    chip.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: AppTextStyles.weightSemiBold,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
