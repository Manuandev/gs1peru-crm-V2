// lib/core/presentation/widgets/app_loading_overlay.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

// Overlay de pantalla completa que bloquea toda interacción mientras se
// espera una operación asíncrona (ej. autocompletado por documento) — el
// Container con color ya capta el hit-test, no hace falta un
// AbsorbPointer/IgnorePointer aparte. Usar dentro de un Stack junto al
// contenido de la pantalla/formulario, como último hijo y solo cuando
// corresponda mostrarlo (`if (cargando) const AppLoadingOverlay(...)`).
class AppLoadingOverlay extends StatelessWidget {
  final String message;

  const AppLoadingOverlay({super.key, this.message = 'Cargando...'});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.black(0.4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: AppSizing.spinnerStrokeMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
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
