// lib/features/solicitudes/presentation/pages/solicitud_participantes_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudParticipantesPage extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudParticipantesPage({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ParticipantesCubit(),
      child: SolicitudParticipantesView(
        solicitud: solicitud,
        modoEdicion: modoEdicion,
      ),
    );
  }
}
