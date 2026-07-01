// lib/features/lead/presentation/widgets/list/lead_list_orden_dropdown.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Pill "Ordenar por: ..." — abre un menú para elegir el criterio de orden.
class LeadListOrdenDropdown extends StatelessWidget {
  final LeadListOrden ordenActual;
  final ValueChanged<LeadListOrden> onChanged;

  const LeadListOrdenDropdown({
    super.key,
    required this.ordenActual,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: PopupMenuButton<LeadListOrden>(
          tooltip: 'Ordenar',
          initialValue: ordenActual,
          onSelected: onChanged,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizing.radiusLg),
          ),
          itemBuilder: (context) => LeadListOrden.values
              .map(
                (o) => PopupMenuItem(
                  value: o,
                  child: Text(o.label, style: AppTextStyles.bodyMedium),
                ),
              )
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  AppIcons.sort,
                  size: AppSizing.iconActionSm,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Ordenar por: ${ordenActual.label}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
