// lib/features/home/presentation/pages/home_page.dart
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
import 'package:app_crm/features/home/index_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExitOnBackWrapper(
      child: BlocProvider(
        create: (context) => HomeBloc(
          getData: GetHomeUseCase(context.read<HomeRepository>()),
        )..add(const HomeStarted()),
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeError) {
              context.showErrorSnack(state.message);
            } else if (state is HomeLoaded) {
              context.updateBadge(
                conversaciones: state.totConversaciones,
                prospectos: state.totProspectos,
                propuestas: state.totPropuestas,
                cobranza: state.totCobranza,
              );
            }
          },
          child: const HomeView(),
        ),
      ),
    );
  }
}
