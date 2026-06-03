// lib/features/lead/presentation/pages/lead_detalle_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetallePage extends StatelessWidget {
  final int idLead;

  const LeadDetallePage({super.key, required this.idLead});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeadDetalleBloc()..add(LeadDetalleStarted(idLead)),
      child: LeadDetalleView(idLead: idLead),
    );
  }
}
