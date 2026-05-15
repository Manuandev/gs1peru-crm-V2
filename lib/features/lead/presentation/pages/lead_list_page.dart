// lib\features\reminder\presentation\pages\reminder_list_page.dart
// ============================================================
// HOME PAGE
// ============================================================
//
// RESPONSABILIDADES:
// - Crear el HomeBloc con sus dependencias
// - Disparar HomeStarted al iniciar
// - Escuchar HomeError para mostrar snackbar
//
// NO HACE:
// - UI          → HomeView
// - Logout      → AppDrawerWidget dispara AuthLogoutRequested al AuthBloc
// - Navegación  → AppWidget escucha AuthBloc y navega
//
// ESTRUCTURA:
// HomePage
//   └── BlocProvider<HomeBloc> (+ HomeStarted)
//         └── BlocListener<HomeBloc> (solo HomeError)
//               └── HomeView
// ============================================================

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            context.updateBadge(leads: state.leads.length);
          }
        },
        child: const LeadListView(),
      ),
    );
  }
}
