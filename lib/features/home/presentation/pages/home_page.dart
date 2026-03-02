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

import 'package:app_crm/core/extensions/badge_extensions.dart';
import 'package:app_crm/core/presentation/widgets/exit_on_back_wrapper.dart';
import 'package:app_crm/features/chat/domain/repositories/i_chats_repository.dart';
import 'package:app_crm/features/home/domain/repositories/i_home_repository.dart';
import 'package:app_crm/features/recordatorio/domain/repositories/i_recordatorios_repository.dart';
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
    return ExitOnBackWrapper(
      child: BlocProvider(
        create: (context) => HomeBloc(
          homeRepository: context.read<IHomeRepository>(),
          recordatoriosRepository: context.read<IRecordatoriosRepository>(),
          chatsRepository: context.read<IChatsRepository>(),
        )..add(const HomeStarted()),
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeError) {
              context.showErrorSnack(state.message);
            } else if (state is HomeLoaded) {
              context.updateBadge(
                leads: state.leads.length,
                chats: state.chats.length,
                recordatorios: state.recordatorios.length,
              );
            }
          },
          child: const HomeView(),
        ),
      ),
    );
  }
}
