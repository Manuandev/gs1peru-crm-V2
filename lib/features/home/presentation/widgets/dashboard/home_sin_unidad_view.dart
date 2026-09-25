// lib/features/home/presentation/widgets/dashboard/home_sin_unidad_view.dart
//
// Home de un asesor SIN unidades de negocio asignadas (el login no devolvió
// ninguna). En vez del embudo y las listas en 0, un aviso sobre la misma ola
// azul del Home. Ver core/CLAUDE.md → "Unidad de negocio".

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class HomeSinUnidadView extends StatelessWidget {
  const HomeSinUnidadView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Scrollable a propósito: vive dentro del RefreshIndicator del Home.
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: HomeOlaFondo(
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              children: [
                Container(
                  width: AppSizing.iconErrorMd,
                  height: AppSizing.iconErrorMd,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: AppColors.opacityIconTint,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.business,
                    size: AppSizing.iconLg,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No tienes una unidad de negocio asignada',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: AppTextStyles.sizeXl,
                    fontWeight: AppTextStyles.weightBold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Pide a tu supervisor que te asigne una. Mientras tanto '
                  'no verás conversaciones, seguimientos, solicitudes ni '
                  'cobranzas.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
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
