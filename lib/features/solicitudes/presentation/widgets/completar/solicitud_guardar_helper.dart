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
  // Paso del wizard que disparó el guardado ('1' Solicitante, '2'
  // Participantes, '3' Facturación, '4' Resumen/Generar) — el SP usa esto
  // para registrar un seguimiento con un texto distinto por paso, ver
  // CSV_SOLICITUD_CUD_APP.sql.
  required String pasoOrigen,
  SolicitudProgreso? progreso,
}) async {
  final formCubit = context.read<SolicitudFormCubit>();
  final formState = formCubit.state;
  final solicitante = formState.solicitante;
  if (solicitante == null) {
    return const CrudError(
      'Completa los datos del solicitante antes de guardar.',
    );
  }

  progreso?.iniciarPaso(
    esBorrador ? 'Guardando solicitud...' : 'Generando solicitud...',
  );

  final participantes = context.read<ParticipantesCubit>().state.participantes;
  final catalogState = context.read<CatalogsBloc>().state;
  final igvPorcentaje = catalogState is CatalogsLoaded
      ? catalogState.igvPorcentaje
      : 0.0;
  final idTipoDocRuc = catalogState is CatalogsLoaded
      ? catalogState.valoresDefecto.idTipoDocRuc
      : '';
  final tiposParticipante = catalogState is CatalogsLoaded
      ? catalogState.tiposParticipante
      : const <TipoParticipanteItem>[];

  final result =
      await GuardarSolicitudUseCase(context.read<SolicitudRepository>()).call(
        numSol: formState.numSol,
        idLead: idLead,
        tipoPersona: formState.tipoPersona,
        solicitante: solicitante,
        facturacion: formState.facturacion,
        participantes: participantes,
        igvPorcentaje: igvPorcentaje,
        esBorrador: esBorrador,
        idTipoDocRuc: idTipoDocRuc,
        pasoOrigen: pasoOrigen,
        tiposParticipante: tiposParticipante,
        cantidadEsperada: formState.cantidadEsperada,
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

  return GuardarArchivoSolicitudUseCase(
    context.read<SolicitudRepository>(),
  ).call(
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
/// (Guardar/Continuar) y por [generarSolicitudCompleta]/[guardarBorradorCompleto]
/// (los 5 botones Guardar/Generar).
///
/// El SP `CSV_SOLICITUD_CUD_APP` (task `'AR'`) filtra el `DELETE` por
/// NUMSOL + tipo de archivo (corregido 2026-07-16) — voucher y O.C. ya no
/// se pisan entre sí al subirse en la misma sesión.
///
/// **Bug real corregido 2026-08-03** — `archivoVoucher`/`archivoOC`
/// (`SolicitudFormCubit.state`) nunca se limpian a `null` después de
/// subirse; antes esta función solo miraba `!= null`, así que cualquier
/// "Siguiente"/"Guardar" posterior en OTRO paso (ej. agregar un
/// participante en el paso 2) volvía a subir el mismo archivo de nuevo, sin
/// que hubiera cambiado. Ahora compara contra `archivoVoucherCargado`/
/// `archivoOCCargado` (el snapshot de "lo último subido con éxito", ver
/// `SolicitudFormState.huboCambios`) — solo sube si es una instancia
/// distinta (el asesor tuvo que volver a elegir un archivo con el picker
/// para que cambie). Importante: `guardarBorradorCompleto()` debe llamar
/// esta función ANTES de `marcarSinCambios()` — si no, el snapshot ya
/// estaría sincronizado y esta comparación nunca detectaría un archivo
/// realmente nuevo en su primera subida.
Future<bool> subirArchivosPendientes(
  BuildContext context, {
  SolicitudProgreso? progreso,
}) async {
  final formState = context.read<SolicitudFormCubit>().state;
  final numSol = formState.numSol;
  if (numSol.isEmpty) return true;

  final voucher = formState.archivoVoucher;
  if (voucher != null && voucher != formState.archivoVoucherCargado) {
    progreso?.iniciarPaso('Subiendo voucher...');
    final ok = await _subirArchivo(context, numSol, 'voucher', voucher);
    if (!ok) return false;
  }

  final oc = formState.archivoOC;
  if (oc != null && oc != formState.archivoOCCargado) {
    progreso?.iniciarPaso('Subiendo O.C....');
    final ok = await _subirArchivo(context, numSol, 'oc', oc);
    if (!ok) return false;
  }

  return true;
}

/// Resultado de [validarSolicitudParaGenerar] cuando algo falta — `paso` es
/// el primer paso incompleto (1 Solicitante, 2 Participantes, 3
/// Facturación), usado para navegar ahí automáticamente antes de mostrar el
/// mensaje.
class SolicitudValidacion {
  final int paso;
  final String mensaje;

  const SolicitudValidacion(this.paso, this.mensaje);
}

/// Valida que la solicitud esté completa para "Generar solicitud" — a
/// diferencia de "Guardar" (borrador), que nunca valida nada y deja pasar
/// cualquier estado a medio llenar. Antes esta validación vivía repartida en
/// el gate de "Continuar" de cada paso (bloqueaba avanzar si faltaba algo);
/// se centralizó acá el 2026-07-16 para que el asesor pueda moverse
/// libremente entre los 4 pasos sin llenar todo de inmediato, y solo se le
/// exija al momento de generar. Retorna `null` si todo está completo.
SolicitudValidacion? validarSolicitudParaGenerar(BuildContext context) {
  final formState = context.read<SolicitudFormCubit>().state;
  final solicitante = formState.solicitante;

  // Mismos campos obligatorios (*) que exige el Form del paso 1 (ver
  // SeccionDatosSolicitante/SeccionInfoComercial en solicitudes/CLAUDE.md) —
  // RUC/razón social solo son obligatorios con tipo de persona Jurídica, con
  // Natural no aplican.
  final solicitanteCompleto =
      solicitante != null &&
      solicitante.tipoDocLabel.isNotEmpty &&
      solicitante.numDoc.trim().isNotEmpty &&
      solicitante.nacionalidadId.isNotEmpty &&
      solicitante.sexoId.isNotEmpty &&
      solicitante.nombres.trim().isNotEmpty &&
      solicitante.apellidoPaterno.trim().isNotEmpty &&
      solicitante.cargo.trim().isNotEmpty &&
      solicitante.celular.trim().isNotEmpty &&
      solicitante.correo.emailValidator == null &&
      (formState.tipoPersona != 'juridica' ||
          (solicitante.ruc.trim().isNotEmpty &&
              solicitante.razonSocial.trim().isNotEmpty));
  if (!solicitanteCompleto) {
    return const SolicitudValidacion(
      1,
      'Completa todos los campos obligatorios (*) del solicitante para generar la solicitud.',
    );
  }

  final participantes = context.read<ParticipantesCubit>().state.participantes;
  if (participantes.isEmpty) {
    return const SolicitudValidacion(
      2,
      'Agrega al menos un participante para generar la solicitud.',
    );
  }

  // Si la solicitud viene de una negociación con precio ya definido, la
  // cantidad de participantes tiene que calzar exacto con la de la
  // negociación — pero SOLO acá, al generar. "Guardar" (borrador) deja
  // pasar con menos participantes sin problema.
  final cantidadEsperada = formState.cantidadEsperada;
  if (cantidadEsperada != null && participantes.length != cantidadEsperada) {
    return SolicitudValidacion(
      2,
      'Esta negociación tiene $cantidadEsperada participante(s) — '
      'registraste ${participantes.length}. Ajusta la lista antes de generar.',
    );
  }

  // Facturación solo es obligatoria si algún participante no es invitado —
  // mismo criterio que "saltar Facturación" en solicitud_participantes_view.dart.
  final catalogState = context.read<CatalogsBloc>().state;
  final tiposParticipante = catalogState is CatalogsLoaded
      ? catalogState.tiposParticipante
      : const <TipoParticipanteItem>[];
  final soloInvitados = participantes.every((p) {
    final tipo = tiposParticipante
        .where((t) => t.id == p.tipoParticipante)
        .firstOrNull;
    return tipo?.esInvitado ?? false;
  });

  if (!soloInvitados) {
    final facturacion = formState.facturacion;
    final idTipoDocRuc = catalogState is CatalogsLoaded
        ? catalogState.valoresDefecto.idTipoDocRuc
        : '';
    final idPais = catalogState is CatalogsLoaded
        ? catalogState.valoresDefecto.idPais
        : '';
    final esRuc = facturacion?.tipoDocId == idTipoDocRuc;
    // País distinto de Perú — Nacionalidad no aplica en ese caso (se manda
    // vacía, ver _SeccionDatosFacturacion), así que no se exige acá.
    final esExtranjero =
        facturacion != null &&
        facturacion.paisId.isNotEmpty &&
        facturacion.paisId != idPais;

    // Mismos campos obligatorios (*) que tenía el viejo gate de "Continuar"
    // del paso 3 — ver _SeccionDatosFacturacion en solicitudes/CLAUDE.md.
    // Moneda ya no se valida acá — el combo se quitó de la UI (pedido de
    // negocio, 2026-07-21), el valor sigue viajando por detrás sin bloquear
    // el guardado.
    final facturacionCompleta =
        facturacion != null &&
        facturacion.comprobanteId.isNotEmpty &&
        facturacion.paisId.isNotEmpty &&
        facturacion.tipoDocId.isNotEmpty &&
        facturacion.numDoc.trim().isNotEmpty &&
        (esExtranjero || facturacion.nacionalidadId.isNotEmpty) &&
        facturacion.nombresRazon.trim().isNotEmpty &&
        (esRuc || facturacion.apellidoPaterno.trim().isNotEmpty) &&
        // Ubigeo (Departamento/Provincia/Distrito) solo aplica con país
        // Perú — mismo criterio que Nacionalidad arriba (2026-07-22).
        (esExtranjero || facturacion.ubigeoCodigo.isNotEmpty) &&
        facturacion.celular.trim().isNotEmpty &&
        facturacion.correo.emailValidator == null &&
        facturacion.direccion.trim().isNotEmpty;

    if (!facturacionCompleta) {
      return const SolicitudValidacion(
        3,
        'Completa todos los campos obligatorios (*) de Facturación para generar la solicitud.',
      );
    }
  }

  return null;
}

/// Aviso de consistencia (no bloquea nada) — si precioBase × cantidad −
/// descuento no calza con el precio total que tenía la negociación de
/// origen (`SolicitudFormState.precioTotalLead`), es señal de que la
/// negociación se editó/desfasó después de fijar esos valores. Retorna
/// `null` si no aplica (no vino de negociación) o si calza.
///
/// Se evalúa **solo** al presionar "Generar solicitud" — nunca al entrar a
/// la página ni al presionar "Guardar" (borrador, se puede editar después
/// sin que nada bloquee ni avise) — decisión de negocio, 2026-07-17. Antes
/// vivía en `solicitud_completar_view.dart._avisarSiPrecioTotalNoCalza()` y
/// se disparaba automáticamente al prellenar el paso 1 desde la negociación.
String? avisoPrecioTotalNoCalza(SolicitudFormState formState) {
  if (formState.precioTotalLead <= 0) return null;
  final cantidad = formState.cantidadEsperada ?? 0;
  final calculado =
      (formState.precioBaseLead * cantidad) - formState.descuentoLead;
  if ((calculado - formState.precioTotalLead).abs() <= 0.01) return null;

  return 'El precio base × cantidad − descuento no coincide con el precio '
      'total de la negociación. Verifica los montos antes de generar la '
      'solicitud.';
}

/// Flujo completo de "Generar solicitud": guarda el CUD (`esBorrador:
/// false`) y, si sale bien, sube voucher/O.C. pendientes con el NUMSOL
/// recién confirmado. Solo se considera generada si TODO sale bien — si el
/// CUD falla no sube nada (retorna ese resultado tal cual); si el CUD sale
/// bien pero un archivo falla, informa el error sin perder el NUMSOL (la
/// solicitud ya quedó creada/actualizada) — el usuario puede volver a
/// presionar "Generar solicitud" para reintentar solo la subida.
///
/// Asume que [validarSolicitudParaGenerar] ya se llamó y retornó `null` —
/// este helper ya no repite esa validación. Si se pasa [progreso], mientras
/// corren los pasos (guardar, subir voucher, subir O.C.) el overlay solo
/// cambia de mensaje, sin mostrar ningún check intermedio — recién cuando
/// TODO termina con éxito se llama `progreso.mostrarExito(...)` (el check
/// animado) y se espera ~1.5s antes de retornar, para que el asesor lo
/// alcance a ver antes de navegar.
Future<CrudResult> generarSolicitudCompleta(
  BuildContext context, {
  required String idLead,
  SolicitudProgreso? progreso,
}) async {
  final result = await guardarSolicitudDesdeWizard(
    context,
    idLead: idLead,
    esBorrador: false,
    pasoOrigen: '4',
    progreso: progreso,
  );
  if (result is! CrudOk) return result;

  // subirArchivosPendientes() puede lanzar AppException (ej. actualización
  // obligatoria pendiente, ver UpdateRequiredInterceptor) — sin este
  // try/catch, la excepción se propagaba sin capturar hasta la vista,
  // dejando el overlay de guardado pegado en "cargando" en vez de mostrar
  // el mensaje real (bug real, 2026-08-07).
  final bool archivosOk;
  try {
    archivosOk = await subirArchivosPendientes(context, progreso: progreso);
  } on AppException catch (e) {
    return CrudError(e.message);
  }
  if (!archivosOk) {
    return const CrudAlert(
      'La solicitud se generó, pero un archivo adjunto no se pudo subir. '
      'Presiona "Generar solicitud" de nuevo para reintentar la subida.',
    );
  }

  if (progreso != null) {
    progreso.mostrarExito('La solicitud se generó correctamente');
    await Future.delayed(const Duration(milliseconds: 1500));
  }
  return result;
}

/// true si esta solicitud ya existe (`numSol` confirmado, se entró a
/// revisarla/editarla) y no hay ningún cambio real pendiente en
/// `SolicitudFormCubit`/`ParticipantesCubit` desde que se cargó o se guardó
/// por última vez. Una solicitud nueva (`numSol` vacío) nunca cae acá —
/// todavía no existe en el backend, tiene que guardarse sí o sí la primera
/// vez.
///
/// Pedido de negocio, 2026-07-24: los 4 botones "Siguiente"/"Guardar" de
/// los pasos 1-3 y Resumen llaman esto ANTES de mostrar cualquier
/// spinner/overlay de guardado — si da `true`, ni siquiera llaman a
/// [guardarBorradorCompleto], solo avanzan/navegan directo, sin que se vea
/// nada de carga en pantalla. Antes, moverse de paso sin editar nada igual
/// mostraba el flujo completo de guardado (spinner + overlay) aunque no
/// hubiera nada que mandar al backend.
bool solicitudSinCambiosPendientes(BuildContext context) {
  final formState = context.read<SolicitudFormCubit>().state;
  if (formState.numSol.isEmpty) return false;
  return !formState.huboCambios &&
      !context.read<ParticipantesCubit>().state.huboCambios;
}

/// Flujo completo de "Guardar" (borrador, `IB_BORRADOR=1`): guarda el CUD y,
/// si sale bien, sube voucher/O.C. pendientes — mismo patrón que
/// [generarSolicitudCompleta], sin ninguna validación previa ("Guardar"
/// nunca valida campos obligatorios, a diferencia de "Generar solicitud").
///
/// Repite la misma verificación de [solicitudSinCambiosPendientes] como red
/// de seguridad (por si algún caller nuevo llama esto directo sin chequear
/// antes) — pero el camino esperado es que el caller ya lo haya chequeado y
/// ni siquiera llegue a llamar esta función cuando no hay nada que guardar,
/// para no mostrar ningún spinner/overlay de más. "Generar solicitud"
/// (`generarSolicitudCompleta`) no pasa por acá — esa acción siempre debe
/// ejecutarse, es la que cambia `IB_BORRADOR` de 1 a 0.
Future<CrudResult> guardarBorradorCompleto(
  BuildContext context, {
  required String idLead,
  // Paso del wizard que disparó el "Guardar" ('1' Solicitante, '2'
  // Participantes, '3' Facturación, '4' Resumen) — ver
  // guardarSolicitudDesdeWizard.
  required String pasoOrigen,
  SolicitudProgreso? progreso,
}) async {
  if (solicitudSinCambiosPendientes(context)) {
    return const CrudOk('');
  }
  final formCubit = context.read<SolicitudFormCubit>();
  final participantesCubit = context.read<ParticipantesCubit>();

  final result = await guardarSolicitudDesdeWizard(
    context,
    idLead: idLead,
    esBorrador: true,
    pasoOrigen: pasoOrigen,
    progreso: progreso,
  );
  if (result is! CrudOk) return result;

  // Ojo — tiene que subir los archivos ANTES de marcarSinCambios(): esa
  // llamada sincroniza archivoVoucherCargado/archivoOCCargado al valor
  // actual, que es justo lo que subirArchivosPendientes() usa para decidir
  // si un archivo es nuevo o ya se subió (ver su comentario). Si el orden
  // se invierte, un archivo recién elegido nunca llegaría a subirse la
  // primera vez (el snapshot ya lo daría por "subido" antes de intentarlo).
  //
  // subirArchivosPendientes() puede lanzar AppException (ej. actualización
  // obligatoria pendiente) — se captura acá para no dejar el overlay de
  // guardado pegado en "cargando" (mismo motivo que en
  // generarSolicitudCompleta, ver su comentario).
  final bool archivosOk;
  try {
    archivosOk = await subirArchivosPendientes(context, progreso: progreso);
  } on AppException catch (e) {
    formCubit.marcarSinCambios();
    participantesCubit.marcarSinCambios();
    return CrudError(e.message);
  }

  formCubit.marcarSinCambios();
  participantesCubit.marcarSinCambios();

  if (!archivosOk) {
    return const CrudAlert(
      'La solicitud se guardó, pero un archivo adjunto no se pudo subir. '
      'Presiona "Guardar" de nuevo para reintentar la subida.',
    );
  }

  if (progreso != null) {
    progreso.mostrarExito('La solicitud se guardó correctamente');
    await Future.delayed(const Duration(milliseconds: 1500));
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
