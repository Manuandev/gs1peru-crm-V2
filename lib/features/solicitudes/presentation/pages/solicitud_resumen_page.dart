// lib/features/solicitudes/presentation/pages/solicitud_resumen_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudResumenPage extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;
  final SolicitudFormCubit formCubit;
  final ParticipantesCubit participantesCubit;

  const SolicitudResumenPage({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
    required this.formCubit,
    required this.participantesCubit,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: formCubit),
        BlocProvider.value(value: participantesCubit),
      ],
      child: SolicitudResumenView(
        solicitud: solicitud,
        modoEdicion: modoEdicion,
      ),
    );
  }
}
