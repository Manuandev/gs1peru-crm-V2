// lib\features\lead\presentation\widgets\lead_list_portrait.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListPortrait extends StatelessWidget {
  final List<LeadEntity> leads;

  const LeadListPortrait({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: LeadCard(
            lead: lead,
            onWhatsAppTap: () {
              // TODO: tu lógica aquí
            },
            onChatTap: () {
              // TODO: tu lógica aquí
            },
            onStarTap: () {
              // TODO: tu lógica aquí
            },
          ),
        );
      },
    );
  }
}
