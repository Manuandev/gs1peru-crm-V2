// lib\features\reminder\presentation\pages\reminder_list_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListPage extends StatelessWidget {
  final LeadType type;
  const LeadListPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeadListBloc(
        GetLeadsUseCase(context.read<LeadRepository>()),
      )..add(LeadListStarted(type)),
      child: BlocListener<LeadListBloc, LeadListState>(
        listener: (context, state) {
          if (state is LeadListError) {
            AppSnackBar.error(context, state.message);
          }
        },
        child: LeadListView(type: type),
      ),
    );
  }
}
