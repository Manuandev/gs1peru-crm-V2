// lib/features/home/presentation/widgets/home_portrait.dart

import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/features/recordatorios/presentation/bloc/recordatorios_state.dart';
import 'package:flutter/material.dart';
import 'package:app_crm/core/constants/app_spacing.dart';

class RecordatoriosPortrait extends StatelessWidget {
  final RecordatoriosLoaded state;

  const RecordatoriosPortrait({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aquí está el resumen de hoy', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),

          ...state.recordatorios.map(
            (lead) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(lead.nomApe),
                subtitle: Text(
    '${lead.accion} - ${lead.aviso} - ${lead.hora}'
    '${lead.comentario.isNotEmpty ? '\n${lead.comentario}' : ''}',
  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
