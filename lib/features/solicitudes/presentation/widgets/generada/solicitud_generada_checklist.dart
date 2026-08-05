// lib/features/solicitudes/presentation/widgets/generada/solicitud_generada_checklist.dart
//
// Card con la lista de verificación decorativa (ficha completa, ficha
// validada, documentos adjuntos, facturación lista), usada por
// SolicitudGeneradaView.

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

class ListaVerificacion extends StatelessWidget {
  const ListaVerificacion({super.key});

  static const _items = [
    ('Ficha completa', 'Toda la información requerida ha sido registrada.'),
    ('Ficha validada', 'La información ha sido revisada y validada.'),
    (
      'Documentos adjuntos',
      'Todos los documentos obligatorios están adjuntos.',
    ),
    (
      'Datos de facturación listos',
      'Información de facturación verificada y completa.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Column(
        children: [
          for (int i = 0; i < _items.length; i++) ...[
            _ItemVerificacion(titulo: _items[i].$1, descripcion: _items[i].$2),
            if (i < _items.length - 1) const Divider(height: 1, thickness: 0.5),
          ],
        ],
      ),
    );
  }
}

class _ItemVerificacion extends StatelessWidget {
  final String titulo;
  final String descripcion;

  const _ItemVerificacion({required this.titulo, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: AppColors.textOnDark,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: AppTextStyles.weightSemiBold,
                    color: AppColors.textPrimary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  descripcion,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
