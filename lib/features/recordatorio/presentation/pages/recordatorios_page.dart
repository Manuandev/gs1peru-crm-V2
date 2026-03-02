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
import 'package:app_crm/features/recordatorio/domain/repositories/i_recordatorios_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/config/router/navigation_extensions.dart';
import '../bloc/recordatorios_bloc.dart';
import '../bloc/recordatorios_event.dart';
import '../bloc/recordatorios_state.dart';
import '../widgets/recordatorios_view.dart';

class RecordatoriosPage extends StatelessWidget {
  const RecordatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecordatoriosBloc(
        recordatoriosRepository: context.read<IRecordatoriosRepository>(),
      )..add(const RecordatoriosStarted()),
      child: BlocListener<RecordatoriosBloc, RecordatoriosState>(
        listener: (context, state) {
          if (state is RecordatoriosError) {
            context.showErrorSnack(state.message);
          } else if (state is RecordatoriosLoaded) {
            context.updateBadge(recordatorios: state.recordatorios.length);
          }
        },
        child: const RecordatoriosView(),
      ),
    );
  }
}
