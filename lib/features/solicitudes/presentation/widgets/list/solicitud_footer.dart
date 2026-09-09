// lib/features/solicitudes/presentation/widgets/list/solicitud_footer.dart
//
// Pie de la lista paginada. 3 modos (igual que SeguimientoFooter):
//   - cargandoMas            → spinner "Cargando más…"
//   - loadMoreError != null  → mensaje + "Reintentar" (la lista queda intacta)
//   - finLista               → "· Fin de la lista ·"
//   - (ninguno)              → espacio mínimo

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudFooter extends StatelessWidget {
  final SolicitudListSuccess estado;
  final VoidCallback onReintentar;

  const SolicitudFooter({
    super.key,
    required this.estado,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    final Widget contenido;

    if (estado.loadMoreError != null) {
      contenido = Column(
        children: [
          Text(
            estado.loadMoreError!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          CustomOutlinedButton(
            text: 'Reintentar',
            icon: AppIcons.refresh,
            onPressed: onReintentar,
          ),
        ],
      );
    } else if (estado.cargandoMas) {
      contenido = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: AppSizing.iconMd,
            height: AppSizing.iconMd,
            child: CircularProgressIndicator(
              strokeWidth: AppSizing.spinnerStrokeMedium,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Cargando más…',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    } else if (estado.finLista && estado.solicitudes.isNotEmpty) {
      contenido = Text(
        '·  Fin de la lista  ·',
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textDisabled),
      );
    } else {
      return const SizedBox(height: AppSpacing.md);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Center(child: contenido),
    );
  }
}
