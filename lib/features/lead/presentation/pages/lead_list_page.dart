// lib\features\reminder\presentation\pages\reminder_list_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListPage extends StatelessWidget {
  const LeadListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeadListBloc(
        GetLeadsUseCase(LeadRepositoryImpl(LeadRemoteDatasource())),
      )..add(const LeadListStarted()),
      child: BlocListener<LeadListBloc, LeadListState>(
        listener: (context, state) {
          if (state is LeadListError) {
            context.showErrorSnack(state.message);
          } else if (state is LeadListLoaded) {
            // context.updateBadge(leads: state.leads.length);
          }
        },
        child: const LeadListView(),
      ),
    );
  }
}
