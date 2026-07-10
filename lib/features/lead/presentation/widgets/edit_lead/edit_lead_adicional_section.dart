// lib/features/lead/presentation/widgets/edit_lead/edit_lead_adicional_section.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';

class EditLeadAdicionalSection extends StatelessWidget {
  final TextEditingController nombreLeadCtrl;
  final TextEditingController modalidadCtrl;
  final bool isLoading;

  const EditLeadAdicionalSection({
    super.key,
    required this.nombreLeadCtrl,
    required this.modalidadCtrl,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormSectionTitle('Información adicional'),
        const SizedBox(height: AppSpacing.md),

        CustomTextField(
          label: 'Nombre de la negociación',
          controller: nombreLeadCtrl,
          enabled: !isLoading,
          dense: true,
          prefixIcon: Icon(
            AppIcons.datosLead,
            color: colorScheme.primary,
            size: AppSizing.iconActionSm,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        CustomTextField(
          label: 'Modalidad',
          controller: modalidadCtrl,
          enabled: !isLoading,
          dense: true,
          prefixIcon: Icon(
            AppIcons.cursoEvento,
            color: colorScheme.primary,
            size: AppSizing.iconActionSm,
          ),
        ),
      ],
    );
  }
}
