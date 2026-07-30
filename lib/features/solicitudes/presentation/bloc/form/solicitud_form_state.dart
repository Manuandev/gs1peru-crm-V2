// lib/features/solicitudes/presentation/bloc/form/solicitud_form_state.dart

part of 'solicitud_form_cubit.dart';

class DatosSolicitante extends Equatable {
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
  // Id real del CargoItem elegido en el combo (CatalogsBloc.cargos) — nuevo
  // 2026-07-30, pedido de negocio ("que se guarde el ID"). `cargo` sigue
  // siendo la descripción (label), se mantiene para mostrar en Resumen/
  // Detalle sin tener que resolver el id contra el catálogo en cada lugar.
  // Puede quedar vacío aunque `cargo` no lo esté (ej. prellenado desde la
  // negociación de origen, que trae solo texto libre sin id de catálogo) —
  // en ese caso el guardado cae a mandar `cargo` como antes, ver
  // solicitud_remote_datasource.dart.
  final String cargoId;
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
    this.cargoId = '',
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

  // Extiende Equatable (no solo campos) para poder comparar por CONTENIDO
  // contra `SolicitudFormState.solicitanteCargado` — ver
  // `SolicitudFormState.huboCambios`. Sin esto, dos instancias con los
  // mismos valores serían "distintas" (comparación por identidad), y
  // cualquier reconstrucción (aunque no cambie nada) marcaría la solicitud
  // como "con cambios pendientes".
  @override
  List<Object?> get props => [
    tipoDocId,
    tipoDocLabel,
    numDoc,
    nacionalidadId,
    nacionalidad,
    sexoId,
    nombres,
    apellidoPaterno,
    apellidoMaterno,
    cargo,
    cargoId,
    celular,
    celularCodigoTelefono,
    correo,
    canalId,
    canalNombre,
    ruc,
    razonSocial,
    solicitanteEsParticipante,
    facturarAlSolicitante,
    archivoVoucherNombre,
    archivoOCNombre,
  ];
}

class DatosFacturacion extends Equatable {
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

  // Ubigeo (Departamento/Provincia/Distrito) — solo aplica cuando el país
  // elegido es Perú (ver SolicitudFacturacionView._esExtranjero). Cada nivel
  // guarda su propio id (código UbigeoItem.dpto/prov/dis, jerárquico — ver
  // core/CLAUDE.md) y su nombre para poder restaurar los 3 combos en cascada
  // al volver "Atrás" y reentrar a este paso, 2026-07-22.
  final String ubigeoDptoId;
  final String ubigeoDptoNombre;
  final String ubigeoProvId;
  final String ubigeoProvNombre;
  final String ubigeoDisId;
  final String ubigeoDisNombre;

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
    this.ubigeoDptoId = '',
    this.ubigeoDptoNombre = '',
    this.ubigeoProvId = '',
    this.ubigeoProvNombre = '',
    this.ubigeoDisId = '',
    this.ubigeoDisNombre = '',
  });

  /// Código completo de 6 dígitos (dpto+prov+dis) que espera `UBIGEO_FAC` en
  /// el CUD — vacío si no se completaron los 3 niveles.
  String get ubigeoCodigo =>
      ubigeoDptoId.isEmpty || ubigeoProvId.isEmpty || ubigeoDisId.isEmpty
      ? ''
      : '$ubigeoDptoId$ubigeoProvId$ubigeoDisId';

  // Ver comentario de `DatosSolicitante.props` — mismo motivo (comparación
  // por contenido contra `SolicitudFormState.facturacionCargado`).
  @override
  List<Object?> get props => [
    comprobanteId,
    comprobante,
    paisId,
    pais,
    monedaId,
    moneda,
    tipoDocId,
    tipoDocLabel,
    numDoc,
    nacionalidadId,
    nacionalidad,
    nombresRazon,
    apellidoPaterno,
    apellidoMaterno,
    celular,
    celularCodigoTelefono,
    correo,
    direccion,
    actividadEconomica,
    nit,
    observaciones,
    ubigeoDptoId,
    ubigeoDptoNombre,
    ubigeoProvId,
    ubigeoProvNombre,
    ubigeoDisId,
    ubigeoDisNombre,
  ];
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
  /// participante — solo quedan para `avisoPrecioTotalNoCalza`
  /// (`solicitud_guardar_helper.dart`).
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

  /// Snapshot de `tipoPersona`/`solicitante`/`facturacion`/`archivoVoucher`/
  /// `archivoOC` tal como quedaron la última vez que se cargó (task 'DT') o
  /// se guardó con éxito esta solicitud — `SolicitudFormCubit.marcarSinCambios()`
  /// los sincroniza a los valores actuales en ambos momentos. `huboCambios`
  /// (abajo) compara CONTENIDO contra estos snapshots, no solo "¿se llamó
  /// guardarSolicitante/guardarFacturacion?" — así, si el asesor edita un
  /// campo y lo vuelve a dejar igual (ej. prende y apaga un switch), el
  /// resultado final se detecta como "sin cambios reales" y
  /// `guardarBorradorCompleto()` no vuelve a guardar. Pedido explícito del
  /// usuario, 2026-07-24 — reemplaza un primer intento con un flag booleano
  /// simple (`huboCambios` como campo, prendido a mano en cada edición) que
  /// no distinguía "tocaste algo" de "el resultado final es distinto".
  final String tipoPersonaCargado;
  final DatosSolicitante? solicitanteCargado;
  final DatosFacturacion? facturacionCargado;
  final PlatformFile? archivoVoucherCargado;
  final PlatformFile? archivoOCCargado;

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
    this.tipoPersonaCargado = 'juridica',
    this.solicitanteCargado,
    this.facturacionCargado,
    this.archivoVoucherCargado,
    this.archivoOCCargado,
  });

  String get tipoPersonaLabel =>
      tipoPersona == 'juridica' ? 'Jurídica' : 'Natural';

  /// true si `tipoPersona`/`solicitante`/`facturacion`/`archivoVoucher`/
  /// `archivoOC` difieren (por contenido) de lo que se cargó o se guardó por
  /// última vez. Usado por `solicitudSinCambiosPendientes()`
  /// (`solicitud_guardar_helper.dart`) para decidir si "Siguiente"/"Guardar"
  /// necesita golpear el backend, o solo dejar avanzar el wizard.
  bool get huboCambios =>
      tipoPersona != tipoPersonaCargado ||
      solicitante != solicitanteCargado ||
      facturacion != facturacionCargado ||
      archivoVoucher != archivoVoucherCargado ||
      archivoOC != archivoOCCargado;

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
    String? tipoPersonaCargado,
    DatosSolicitante? solicitanteCargado,
    DatosFacturacion? facturacionCargado,
    bool limpiarFacturacionCargado = false,
    PlatformFile? archivoVoucherCargado,
    bool limpiarArchivoVoucherCargado = false,
    PlatformFile? archivoOCCargado,
    bool limpiarArchivoOCCargado = false,
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
    tipoPersonaCargado: tipoPersonaCargado ?? this.tipoPersonaCargado,
    solicitanteCargado: solicitanteCargado ?? this.solicitanteCargado,
    facturacionCargado: limpiarFacturacionCargado
        ? null
        : (facturacionCargado ?? this.facturacionCargado),
    archivoVoucherCargado: limpiarArchivoVoucherCargado
        ? null
        : (archivoVoucherCargado ?? this.archivoVoucherCargado),
    archivoOCCargado: limpiarArchivoOCCargado
        ? null
        : (archivoOCCargado ?? this.archivoOCCargado),
  );
}
