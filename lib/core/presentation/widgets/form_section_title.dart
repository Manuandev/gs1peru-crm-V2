// lib/core/presentation/widgets/form_section_title.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

/// Título de sección para formularios — texto en mayúsculas con letra espaciada.
/// Reemplaza el patrón _tituloSeccion(String) usado en múltiples formularios.
class FormSectionTitle extends StatelessWidget {
  final String titulo;
  const FormSectionTitle(this.titulo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo.toUpperCase(),
      style: AppTextStyles.labelMedium.copyWith(
        color:        AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}
