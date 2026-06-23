// lib/features/lead/presentation/pages/lead_list_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadListPage extends StatelessWidget {
  const LeadListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LeadListBloc(
            GetLeadsUseCase(context.read<LeadRepository>()),
            ToggleFavoritoLeadUseCase(context.read<LeadRepository>()),
          )..add(const LeadListStarted()),
        ),
        BlocProvider(
          create: (_) => LeadListVistaCubit()..cargar(),
        ),
      ],
      child: BlocListener<LeadListBloc, LeadListState>(
        listener: (context, state) {
          if (state is LeadListError) {
            AppSnackBar.error(context, state.message);
          }
        },
        child: const LeadListView(),
      ),
    );
  }
}
