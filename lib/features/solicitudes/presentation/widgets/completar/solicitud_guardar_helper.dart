// lib/features/solicitudes/presentation/widgets/completar/solicitud_guardar_helper.dart
//
// Punto único donde se arma + llama GuardarSolicitudUseCase para los
// botones "Guardar" (borrador, IB_BORRADOR=1) y "Generar solicitud" (final,
// IB_BORRADOR=0) de los 4 pasos del wizard — evita repetir en cada paso la
// lectura de SolicitudFormCubit/ParticipantesCubit/CatalogsBloc.

import 'package:flutter/widgets.dart';

import 'package:app_crm/index_dependencies.dart'; // context.read, PlatformFile
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

Future<CrudResult> guardarSolicitudDesdeWizard(
  BuildContext context, {
  String idLead = '',
  required bool esBorrador,
}) async {
  final formCubit = context.read<SolicitudFormCubit>();
  final formState = formCubit.state;
  final solicitante = formState.solicitante;
  if (solicitante == null) {
    return const CrudError('Completa los datos del solicitante antes de guardar.');
  }

  final participantes = context
      .read<ParticipantesCubit>()
      .state
      .participantes;
  final catalogState = context.read<CatalogsBloc>().state;
  final igvPorcentaje = catalogState is CatalogsLoaded
      ? catalogState.igvPorcentaje
      : 0.0;

  final result = await GuardarSolicitudUseCase(
    context.read<SolicitudRepository>(),
  ).call(
    numSol: formState.numSol,
    idLead: idLead,
    tipoPersona: formState.tipoPersona,
    solicitante: solicitante,
    facturacion: formState.facturacion,
    participantes: participantes,
    igvPorcentaje: igvPorcentaje,
    esBorrador: esBorrador,
    descuento: formState.descuentoLead,
  );

  // La primera vez que se crea (numSol venía vacío), el backend genera el
  // NUMSOL real y lo devuelve en CrudOk.data — hay que guardarlo para que
  // el próximo "Guardar" actualice esta misma solicitud en vez de crear
  // otra.
  if (result case CrudOk(:final data) when data != null && data.isNotEmpty) {
    formCubit.actualizarNumSol(data);
  }

  return result;
}

Future<bool> _subirArchivo(
  BuildContext context,
  String numSol,
  String tipo,
  PlatformFile archivo,
) async {
  final bytes = archivo.bytes;
  if (bytes == null) return false;

  final ext = archivo.extension ?? 'pdf';
  final sufijo = '.$ext';
  final nombre = archivo.name.toLowerCase().endsWith(sufijo.toLowerCase())
      ? archivo.name.substring(0, archivo.name.length - sufijo.length)
      : archivo.name;

  return GuardarArchivoSolicitudUseCase(context.read<SolicitudRepository>())
      .call(
        numSol: numSol,
        tipo: tipo,
        fileName: nombre,
        fileExt: ext,
        fileBytes: bytes,
      );
}

/// Sube voucher/O.C. pendientes (`SolicitudFormCubit.state`) usando el
/// NUMSOL ya confirmado — no hace nada (retorna `true`) si todavía no hay
/// NUMSOL o no hay archivos adjuntados. Usado por el paso 1
/// (Guardar/Continuar) y por [generarSolicitudCompleta] (Resumen).
///
/// OJO — riesgo real en el SP: el task `'AR'` de `CSV_SOLICITUD_CUD_APP`
/// borra TODOS los archivos de ese NUMSOL antes de insertar el nuevo (no
/// solo el tipo que se sube) — si hay voucher y O.C. juntos, la segunda
/// llamada pisa a la primera. Sin confirmar con backend si conviene mandar
/// ambos juntos en un solo `'AR'`.
Future<bool> subirArchivosPendientes(BuildContext context) async {
  final formState = context.read<SolicitudFormCubit>().state;
  final numSol = formState.numSol;
  if (numSol.isEmpty) return true;

  final voucher = formState.archivoVoucher;
  if (voucher != null) {
    final ok = await _subirArchivo(context, numSol, 'voucher', voucher);
    if (!ok) return false;
  }

  final oc = formState.archivoOC;
  if (oc != null) {
    final ok = await _subirArchivo(context, numSol, 'oc', oc);
    if (!ok) return false;
  }

  return true;
}

/// Flujo completo de "Generar solicitud": guarda el CUD (`esBorrador:
/// false`) y, si sale bien, sube voucher/O.C. pendientes con el NUMSOL
/// recién confirmado. Solo se considera generada si TODO sale bien — si el
/// CUD falla no sube nada (retorna ese resultado tal cual); si el CUD sale
/// bien pero un archivo falla, informa el error sin perder el NUMSOL (la
/// solicitud ya quedó creada/actualizada) — el usuario puede volver a
/// presionar "Generar solicitud" para reintentar solo la subida.
Future<CrudResult> generarSolicitudCompleta(
  BuildContext context, {
  required String idLead,
}) async {
  // Si la solicitud viene de una negociación con precio ya definido, la
  // cantidad de participantes tiene que calzar exacto con la de la
  // negociación — pero SOLO acá, al generar. Cualquier "Guardar" (borrador)
  // de los 4 pasos deja pasar con menos participantes sin problema.
  final cantidadEsperada = context.read<SolicitudFormCubit>().state.cantidadEsperada;
  if (cantidadEsperada != null) {
    final cantidadActual = context
        .read<ParticipantesCubit>()
        .state
        .participantes
        .length;
    if (cantidadActual != cantidadEsperada) {
      return CrudError(
        'Esta negociación tiene $cantidadEsperada participante(s) — '
        'registraste $cantidadActual. Ajusta la lista antes de generar.',
      );
    }
  }

  final result = await guardarSolicitudDesdeWizard(
    context,
    idLead: idLead,
    esBorrador: false,
  );
  if (result is! CrudOk) return result;

  final archivosOk = await subirArchivosPendientes(context);
  if (!archivosOk) {
    return const CrudAlert(
      'La solicitud se generó, pero un archivo adjunto no se pudo subir. '
      'Presiona "Generar solicitud" de nuevo para reintentar la subida.',
    );
  }

  return result;
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
