// lib/features/lead/presentation/widgets/detalle/lead_detalle_actions.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

class LeadDetalleActions extends StatelessWidget {
  const LeadDetalleActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BotonAccion(
                icono: FaIcon(
                  AppIconsSocial.whatsapp,
                  color: AppIconsSocial.colorCanal(1),
                  size: AppSizing.iconMd,
                ),
                label: 'WhatsApp',
                onTap: () {},
              ),
              _BotonAccion(
                icono: Icon(AppIcons.phone, size: AppSizing.iconMd, color: AppColors.primary),
                label: 'Llamar',
                onTap: () {},
              ),
              _BotonAccion(
                icono: Icon(AppIcons.notification, size: AppSizing.iconMd, color: AppColors.primary),
                label: 'Recordatorio',
                onTap: () {},
              ),
              _BotonAccion(
                icono: Icon(AppIcons.edit, size: AppSizing.iconMd, color: AppColors.primary),
                label: 'Editar',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final Widget icono;
  final String label;
  final VoidCallback onTap;

  const _BotonAccion({
    required this.icono,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icono,
            const SizedBox(height: AppSpacing.xxs),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
