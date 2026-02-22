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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/config/router/navigation_extensions.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()
        // Todo: con dependencias sería:
        // create: (context) => HomeBloc(
        //   homeRepository: context.read<IHomeRepository>(),
        // )
        ..add(const HomeStarted()),
      child: BlocListener<HomeBloc, HomeState>(
        // Solo escucha errores para mostrar snackbar
        listenWhen: (_, current) => current is HomeError,
        listener: (context, state) {
          context.showErrorSnack((state as HomeError).message);
        },
        child: const HomeView(),
      ),
    );
  }
}
