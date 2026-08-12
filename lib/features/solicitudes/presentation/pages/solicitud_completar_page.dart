// lib/features/solicitudes/presentation/pages/solicitud_completar_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudCompletarPage extends StatelessWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudCompletarPage({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Los datos de la negociación de origen (si `solicitud.idLead` no
        // está vacío) se traen dentro de SolicitudCompletarView._cargarDetalle()
        // vía GetLeadDetalleUseCase — ya no se siembran acá.
        BlocProvider(create: (_) => SolicitudFormCubit()),
        BlocProvider(create: (_) => ParticipantesCubit()),
      ],
      child: SolicitudWizardView(
        solicitud: solicitud,
        modoEdicion: modoEdicion,
      ),
    );
  }
}
