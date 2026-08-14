// lib/features/lead/presentation/pages/lead_list_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListPage extends StatelessWidget {
  final LeadListFiltro? filtroInicial;

  const LeadListPage({super.key, this.filtroInicial});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LeadListBloc(
            GetLeadsUseCase(context.read<LeadRepository>()),
            filtroInicial: filtroInicial,
          )..add(const LeadListStarted()),
        ),
      ],
      child: BlocListener<LeadListBloc, LeadListState>(
        listener: (context, state) {
          if (state is LeadListError) {
            AppSnackBar.error(context, state.message);
          } else if (state is LeadListSuccess) {
            context.updateBadge(seguimientos: state.activos);
          }
        },
        child: const LeadListView(),
      ),
    );
  }
}
