// lib/features/solicitudes/presentation/pages/solicitud_list_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudListPage extends StatelessWidget {
  const SolicitudListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SolicitudListBloc(
        GetSolicitudesUseCase(context.read<SolicitudRepository>()),
      )..add(const SolicitudListStarted()),
      child: BlocListener<SolicitudListBloc, SolicitudListState>(
        listener: (context, state) {
          if (state is SolicitudListError) {
            AppSnackBar.error(context, state.message);
          }
        },
        child: const SolicitudListView(),
      ),
    );
  }
}
