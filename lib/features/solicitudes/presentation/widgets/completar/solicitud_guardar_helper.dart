// lib/features/solicitudes/presentation/widgets/completar/solicitud_guardar_helper.dart
//
// Punto único donde se arma + llama GuardarSolicitudUseCase para los
// botones "Guardar" (borrador, IB_BORRADOR=1) y "Generar solicitud" (final,
// IB_BORRADOR=0) de los 4 pasos del wizard — evita repetir en cada paso la
// lectura de SolicitudFormCubit/ParticipantesCubit/CatalogsBloc.

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

Future<CrudResult> guardarSolicitudDesdeWizard(
  BuildContext context, {
  required String numSol,
  String idLead = '',
  required bool esBorrador,
}) {
  final formState = context.read<SolicitudFormCubit>().state;
  final solicitante = formState.solicitante;
  if (solicitante == null) {
    return Future.value(
      const CrudError('Completa los datos del solicitante antes de guardar.'),
    );
  }

  final participantes = context
      .read<ParticipantesCubit>()
      .state
      .participantes;
  final catalogState = context.read<CatalogsBloc>().state;
  final igvPorcentaje = catalogState is CatalogsLoaded
      ? catalogState.igvPorcentaje
      : 0.0;

  return GuardarSolicitudUseCase(context.read<SolicitudRepository>()).call(
    numSol: numSol,
    idLead: idLead,
    tipoPersona: formState.tipoPersona,
    solicitante: solicitante,
    facturacion: formState.facturacion,
    participantes: participantes,
    igvPorcentaje: igvPorcentaje,
    esBorrador: esBorrador,
  );
}

/// Traduce un [CrudResult] a un snackbar — mismo criterio en los 4 pasos.
void mostrarResultadoGuardarSolicitud(BuildContext context, CrudResult result) {
  switch (result) {
    case CrudOk(:final message):
      AppSnackBar.success(
        context,
        message.isEmpty ? 'Solicitud guardada correctamente.' : message,
      );
    case CrudAlert(:final message):
      AppSnackBar.warning(context, message);
    case CrudError(:final message):
      AppSnackBar.error(context, message);
    case CrudNoInternet():
      AppSnackBar.error(context, 'Sin conexión a Internet.');
    case CrudEmpty():
      AppSnackBar.error(context, 'Respuesta inesperada del servidor.');
  }
}
