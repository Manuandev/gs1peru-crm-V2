// lib/features/solicitudes/presentation/bloc/form/solicitud_form_state.dart

part of 'solicitud_form_cubit.dart';

class DatosSolicitante {
  final String tipoDocId;
  final String tipoDocLabel;
  final String numDoc;
  final String nacionalidadId;
  final String nacionalidad;
  final String sexoId;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String cargo;
  final String celular;
  final String celularCodigoTelefono;
  final String correo;
  final int? canalId;
  final String canalNombre;
  final String ruc;
  final String razonSocial;
  final bool solicitanteEsParticipante;
  final bool facturarAlSolicitante;
  final String archivoVoucherNombre;
  final String archivoOCNombre;

  const DatosSolicitante({
    this.tipoDocId = '',
    required this.tipoDocLabel,
    required this.numDoc,
    this.nacionalidadId = '',
    required this.nacionalidad,
    required this.sexoId,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.cargo,
    required this.celular,
    this.celularCodigoTelefono = '',
    required this.correo,
    this.canalId,
    required this.canalNombre,
    required this.ruc,
    required this.razonSocial,
    required this.solicitanteEsParticipante,
    required this.facturarAlSolicitante,
    this.archivoVoucherNombre = '',
    this.archivoOCNombre = '',
  });

  String get nombreCompleto => [
    nombres,
    apellidoPaterno,
    apellidoMaterno,
  ].where((s) => s.isNotEmpty).join(' ');

  String get documento =>
      tipoDocLabel.isNotEmpty ? '$tipoDocLabel $numDoc' : numDoc;

  String get canalTexto => canalNombre.isEmpty ? '—' : canalNombre;
}

class DatosFacturacion {
  final String comprobanteId;
  final String comprobante;
  final String paisId;
  final String pais;
  final String monedaId;
  final String moneda;
  final String tipoDocId;
  final String tipoDocLabel;
  final String numDoc;
  final String nacionalidadId;
  final String nacionalidad;
  final String nombresRazon;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String celular;
  final String celularCodigoTelefono;
  final String correo;
  final String direccion;
  final String actividadEconomica;
  final String nit;
  final String observaciones;

  const DatosFacturacion({
    required this.comprobanteId,
    required this.comprobante,
    required this.paisId,
    required this.pais,
    required this.monedaId,
    required this.moneda,
    this.tipoDocId = '',
    required this.tipoDocLabel,
    required this.numDoc,
    this.nacionalidadId = '',
    this.nacionalidad = '',
    required this.nombresRazon,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.celular,
    this.celularCodigoTelefono = '',
    required this.correo,
    required this.direccion,
    required this.actividadEconomica,
    required this.nit,
    required this.observaciones,
  });
}

class SolicitudFormState {
  /// 'juridica' | 'natural' — compartido por los pasos 1 (solicitante) y 3
  /// (facturación): ambos representan el mismo dato, no dos independientes.
  final String tipoPersona;

  /// NUMSOL de la solicitud — vacío mientras es una creación nueva. Se
  /// setea una vez al entrar al wizard (con el NUMSOL real si se edita una
  /// solicitud existente) y se actualiza sola con el NUMSOL que devuelve el
  /// backend tras el primer guardado exitoso — así cualquier "Guardar"
  /// posterior en la misma sesión actualiza en vez de crear otra solicitud.
  /// Ver `guardarSolicitudDesdeWizard()`.
  final String numSol;
  final DatosSolicitante? solicitante;
  final DatosFacturacion? facturacion;

  /// Voucher/O.C. adjuntados en el paso 1 — viven acá (no en el estado local
  /// de `solicitud_completar_view.dart`) para que "Generar solicitud"
  /// (Resumen) también pueda subirlos, no solo "Guardar"/"Continuar" del
  /// paso 1. Ver `SolicitudFormCubit.guardarArchivoVoucher/OC`.
  final PlatformFile? archivoVoucher;
  final PlatformFile? archivoOC;

  /// Datos "de paso" de la negociación de origen — presentes tanto al crear
  /// una solicitud nueva desde una negociación con precio ya definido (ver
  /// `SolicitudFormCubit.sembrarDatosNegociacion`) como al reabrir una ya
  /// guardada que tenga una (recuperada por `idLeadOrigen`, ver
  /// `solicitud_completar_view.dart._cargarDetalle()` y CLAUDE.md — desde el
  /// 2026-07-16 esto ya NO queda `null` al editar). `cantidadEsperada` no
  /// nulo activa: la moneda del paso 3 queda fija en `idMonedaBloqueada`, la
  /// cantidad de participantes debe calzar exacto al generar (ver
  /// `validarSolicitudParaGenerar`), y el importe sugerido de un participante
  /// nuevo se calcula desde `precioTotalLead`/`cantidadEsperada` (ver
  /// `_importeFijo` en `solicitud_participantes_view.dart`) — el importe
  /// sigue siendo siempre editable, esto es solo la sugerencia inicial.
  /// `precioBaseLead`/`descuentoLead` ya no se usan para el importe del
  /// participante — solo quedan para `_avisarSiPrecioTotalNoCalza`.
  final int? cantidadEsperada;
  final double precioBaseLead;
  final double descuentoLead;
  final String? idMonedaBloqueada;

  /// Precio total de la negociación (`Negociacion.precio`, "Costo final") —
  /// no bloquea nada por sí solo, es solo el valor de referencia contra el
  /// que `_cargarDetalle()` (paso 1) valida que `precioBaseLead × cantidadEsperada
  /// − descuentoLead` calce (ver solicitudes/CLAUDE.md). `0` = no vino de
  /// una negociación (`cantidadEsperada == null`) o la negociación no tenía
  /// precio definido todavía.
  final double precioTotalLead;

  /// Datos de contacto de la negociación de origen — mismo momento/mismo
  /// candado que `cantidadEsperada` (solo se siembran al crear desde
  /// "Generar solicitud", nunca al editar). Se usan **solo para prellenar**
  /// los controllers del paso 1 en `_cargarDetalle()` — a diferencia de
  /// `precioBaseLead`/`descuentoLead`/`idMonedaBloqueada`, el asesor SÍ puede
  /// editarlos después (no hay ninguna regla de negocio que los bloquee).
  final String nombresLead;
  final String apellidoPaternoLead;
  final String apellidoMaternoLead;
  final String nombreEmpresaLead;
  final String correoLead;
  final String celularLead;
  final String celularCodigoTelefonoLead;

  /// RUC de la empresa de la negociación (`Negociacion.ruc`, `EM.RUC`) —
  /// mismo candado/mismo trato de solo-prellenado que el resto de datos de
  /// contacto de arriba.
  final String rucLead;

  /// Cargo del contacto de la negociación (`Negociacion.cargo`,
  /// `CT.ID_CARGO`, ya viene como texto libre) — mismo candado/mismo trato
  /// de solo-prellenado que el resto de datos de contacto de arriba.
  final String cargoLead;

  const SolicitudFormState({
    this.tipoPersona = 'juridica',
    this.numSol = '',
    this.solicitante,
    this.facturacion,
    this.archivoVoucher,
    this.archivoOC,
    this.cantidadEsperada,
    this.precioBaseLead = 0,
    this.descuentoLead = 0,
    this.idMonedaBloqueada,
    this.precioTotalLead = 0,
    this.nombresLead = '',
    this.apellidoPaternoLead = '',
    this.apellidoMaternoLead = '',
    this.nombreEmpresaLead = '',
    this.correoLead = '',
    this.celularLead = '',
    this.celularCodigoTelefonoLead = '',
    this.rucLead = '',
    this.cargoLead = '',
  });

  String get tipoPersonaLabel =>
      tipoPersona == 'juridica' ? 'Jurídica' : 'Natural';

  SolicitudFormState copyWith({
    String? tipoPersona,
    String? numSol,
    DatosSolicitante? solicitante,
    DatosFacturacion? facturacion,
    PlatformFile? archivoVoucher,
    bool limpiarArchivoVoucher = false,
    PlatformFile? archivoOC,
    bool limpiarArchivoOC = false,
    int? cantidadEsperada,
    double? precioBaseLead,
    double? descuentoLead,
    String? idMonedaBloqueada,
    double? precioTotalLead,
    String? nombresLead,
    String? apellidoPaternoLead,
    String? apellidoMaternoLead,
    String? nombreEmpresaLead,
    String? correoLead,
    String? celularLead,
    String? celularCodigoTelefonoLead,
    String? rucLead,
    String? cargoLead,
  }) => SolicitudFormState(
    tipoPersona: tipoPersona ?? this.tipoPersona,
    numSol: numSol ?? this.numSol,
    solicitante: solicitante ?? this.solicitante,
    facturacion: facturacion ?? this.facturacion,
    archivoVoucher: limpiarArchivoVoucher
        ? null
        : (archivoVoucher ?? this.archivoVoucher),
    archivoOC: limpiarArchivoOC ? null : (archivoOC ?? this.archivoOC),
    cantidadEsperada: cantidadEsperada ?? this.cantidadEsperada,
    precioBaseLead: precioBaseLead ?? this.precioBaseLead,
    descuentoLead: descuentoLead ?? this.descuentoLead,
    idMonedaBloqueada: idMonedaBloqueada ?? this.idMonedaBloqueada,
    precioTotalLead: precioTotalLead ?? this.precioTotalLead,
    nombresLead: nombresLead ?? this.nombresLead,
    apellidoPaternoLead: apellidoPaternoLead ?? this.apellidoPaternoLead,
    apellidoMaternoLead: apellidoMaternoLead ?? this.apellidoMaternoLead,
    nombreEmpresaLead: nombreEmpresaLead ?? this.nombreEmpresaLead,
    correoLead: correoLead ?? this.correoLead,
    celularLead: celularLead ?? this.celularLead,
    celularCodigoTelefonoLead:
        celularCodigoTelefonoLead ?? this.celularCodigoTelefonoLead,
    rucLead: rucLead ?? this.rucLead,
    cargoLead: cargoLead ?? this.cargoLead,
  );
}
