// lib/core/presentation/widgets/form_field_row.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

/// Fila de dos campos con ancho igual, separados por [AppSpacing.sm].
/// Reemplaza el patrón _buildFila(izq, der) usado en múltiples formularios.
class FormFieldRow extends StatelessWidget {
  final Widget izquierdo;
  final Widget derecho;

  const FormFieldRow({
    super.key,
    required this.izquierdo,
    required this.derecho,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: izquierdo),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: derecho),
      ],
    );
  }
}
