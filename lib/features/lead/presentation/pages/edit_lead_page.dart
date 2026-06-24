// lib/features/lead/presentation/pages/edit_lead_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EditLeadPage extends StatelessWidget {
  final int idNumero;
  const EditLeadPage({super.key, required this.idNumero});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditLeadBloc()..add(const EditLeadStarted()),
      child: const EditLeadView(),
    );
  }
}
