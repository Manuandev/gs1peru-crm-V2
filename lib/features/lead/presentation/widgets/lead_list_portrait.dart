// lib\features\lead\presentation\widgets\lead_list_portrait.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:flutter/material.dart';

class LeadListPortrait extends StatelessWidget {
  final LeadListLoaded state;

  const LeadListPortrait({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aquí está el resumen de hoy', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),

          ...state.leads.map(
            (lead) => Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(lead.idLead),
                subtitle: Text(
                  '${lead.dni} - ${lead.dia} - ${lead.hora}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
