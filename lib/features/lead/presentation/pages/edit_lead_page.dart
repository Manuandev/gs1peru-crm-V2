// lib/features/chat/presentation/pages/edit_lead_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

class EditLeadPage extends StatelessWidget {
  final InfoLead lead;

  const EditLeadPage({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditLeadBloc()..add(const EditLeadStarted()),
      child: BlocListener<EditLeadBloc, EditLeadState>(
        listener: (context, state) {},
        child: EditLeadView(lead: lead),
      ),
    );
  }
}
