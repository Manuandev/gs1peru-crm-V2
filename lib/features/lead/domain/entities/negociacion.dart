// lib/features/lead/domain/entities/negociacion_lead.dart

import 'package:app_crm/index_dependencies.dart';

/// Acción disponible en el botón de solicitud de una negociación — ver
/// [Negociacion.accionSolicitud].
enum SolicitudAccion { generar, editar, ver }

class Negociacion extends Equatable {
  final int idLead;

  final String nombre;
  final String modalidad;

  final int cantidad;
  final double precioBase;
  final double descuento;
  final double precio;
  final String fechaHoraInteraccion;
  final String fechaHoraCreacion;

  final String idEstado;
  final String descripcionEstado;

  final String idEstadoPadre;
  final String descripcionEstadoPadre;

  final int idCampania;
  final String nombreCampania;

  final int idOportunidad;
  final String nombreOportunidad;

  final int idCanal;
  final String descripcionCanal;

  final int idInteres;
  final String descripcionInteres;

  final bool activo;

  // codargu de SYSTABEXTER02 (CODTABLA='MON') — LD.ID_TIP_MONEDA. String para
  // matchear directo contra MonedaItem.id en el combo de CatalogsBloc.
  final String idMoneda;

  // CL.CT_LEADS — cantidad total de leads del número de este contacto
  // (sin filtrar por activo). Solo la traen 'LS' y 'DT' (no 'LN', que ya es
  // el historial completo).
  final int totalLeadsNumero;

  // Contacto/número — de solo lectura en el form de edición. Con default
  // porque no todos los SPs que alimentan Negociacion los traen (ej. 'LN' —
  // historial de negociaciones). Se completan desde el SP de detalle ('DT')
  // o desde el Chat ya cargado en lista.
  final int idNumero;
  final String prefijoPais;
  final String numero;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String nombreEmpresa;
  final String correo;

  // RUC de la empresa (EM.RUC) — mismo candado que nombres/apellidos/correo
  // de arriba: solo lo trae 'DT'/'DN', 'LN' lo deja vacío.
  final String ruc;

  final String numSol;
  final int idEstadoSol;

  // Id de la conversación (T_CONVERSACION_CAB) más reciente de este número —
  // mismo dato que Numero.idChatCab en el listado. 0 si el número nunca
  // conversó. Solo lo trae 'DT'/'DN' (columna 31, CCU.ID_CONVERSACION_CAB).
  final int idChatCab;

  // Fecha del primer mensaje del CLIENTE en la conversación de [idChatCab]
  // — mismo dato que Numero.fechaPrimerMensajeCliente en el listado, ancla
  // de la ventana de chat abierto (TDE). 'DT'/'DN' la traen desde
  // 2026-07-15 (columna 40, PM.FC_PRIMER_MSJ_CLI).
  final String fechaPrimerMensajeCliente;

  /// Id de estado a mostrar/agrupar: si hay un sub-estado (idEstadoPadre
  /// presente), se usa el padre — ej. "Con ficha" agrupa bajo "En desarrollo".
  String get idEstadoEfectivo =>
      idEstadoPadre.isNotEmpty ? idEstadoPadre : idEstado;

  /// Descripción de estado a mostrar — misma regla que [idEstadoEfectivo].
  String get estadoEfectivo => idEstadoPadre.isNotEmpty
      ? (descripcionEstadoPadre.isNotEmpty
            ? descripcionEstadoPadre
            : descripcionEstado)
      : descripcionEstado;

  /// true si ya existe una solicitud generada para esta negociación
  /// (NUMSOL no vacío) — a partir de acá la negociación deja de ser
  /// editable, sin importar su estado.
  bool get tieneSolicitud => numSol.trim().isNotEmpty;

  /// Qué acción corresponde al botón de solicitud: sin NUMSOL, generar una
  /// nueva; con NUMSOL y estado de gestión en 0 (borrador), editarla; con
  /// NUMSOL y estado de gestión mayor a 0 (ya procesada), solo verla.
  SolicitudAccion get accionSolicitud {
    if (!tieneSolicitud) return SolicitudAccion.generar;
    return idEstadoSol == 0 ? SolicitudAccion.editar : SolicitudAccion.ver;
  }

  /// Nombre completo del contacto — vacío si no hay nombres/apellidos
  /// registrados (solo lo trae 'DT', no 'LN').
  String get nombreCompleto => [
    nombres,
    apellidoPaterno,
    apellidoMaterno,
  ].where((p) => p.trim().isNotEmpty).join(' ');

  /// Teléfono con prefijo — vacío si no hay número registrado.
  String get telefonoCompleto => '$prefijoPais $numero'.trim();

  const Negociacion({
    required this.idLead,
    required this.nombre,
    required this.modalidad,
    required this.cantidad,
    required this.precioBase,
    required this.descuento,
    required this.precio,
    required this.fechaHoraInteraccion,
    required this.fechaHoraCreacion,
    required this.idEstado,
    required this.descripcionEstado,
    required this.idEstadoPadre,
    required this.descripcionEstadoPadre,
    required this.idCampania,
    required this.nombreCampania,
    required this.idOportunidad,
    required this.nombreOportunidad,
    required this.idCanal,
    required this.descripcionCanal,
    required this.idInteres,
    required this.descripcionInteres,
    required this.activo,
    this.idMoneda = '',
    this.totalLeadsNumero = 0,
    this.idNumero = 0,
    this.prefijoPais = '',
    this.numero = '',
    this.nombres = '',
    this.apellidoPaterno = '',
    this.apellidoMaterno = '',
    this.nombreEmpresa = '',
    this.correo = '',
    this.ruc = '',
    this.numSol = '',
    this.idEstadoSol = 0,
    this.idChatCab = 0,
    this.fechaPrimerMensajeCliente = '',
  });

  @override
  List<Object?> get props => [
    idLead,
    nombre,
    modalidad,
    cantidad,
    precioBase,
    descuento,
    precio,
    fechaHoraInteraccion,
    fechaHoraCreacion,
    idEstado,
    descripcionEstado,
    idEstadoPadre,
    descripcionEstadoPadre,
    idCampania,
    nombreCampania,
    idOportunidad,
    nombreOportunidad,
    idCanal,
    descripcionCanal,
    idInteres,
    descripcionInteres,
    activo,
    idMoneda,
    totalLeadsNumero,
    idNumero,
    prefijoPais,
    numero,
    nombres,
    apellidoPaterno,
    apellidoMaterno,
    nombreEmpresa,
    correo,
    ruc,
    numSol,
    idEstadoSol,
    idChatCab,
    fechaPrimerMensajeCliente,
  ];

  Negociacion copyWith({
    int? idLead,
    String? nombre,
    String? modalidad,
    int? cantidad,
    double? precioBase,
    double? descuento,
    double? precio,
    String? fechaHoraInteraccion,
    String? fechaHoraCreacion,
    String? idEstado,
    String? descripcionEstado,
    String? idEstadoPadre,
    String? descripcionEstadoPadre,
    int? idCampania,
    String? nombreCampania,
    int? idOportunidad,
    String? nombreOportunidad,
    int? idCanal,
    String? descripcionCanal,
    int? idInteres,
    String? descripcionInteres,
    bool? activo,
    String? idMoneda,
    int? totalLeadsNumero,
    int? idNumero,
    String? prefijoPais,
    String? numero,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? nombreEmpresa,
    String? correo,
    String? ruc,
    String? numSol,
    int? idEstadoSol,
    int? idChatCab,
    String? fechaPrimerMensajeCliente,
  }) {
    return Negociacion(
      idLead: idLead ?? this.idLead,
      nombre: nombre ?? this.nombre,
      modalidad: modalidad ?? this.modalidad,
      cantidad: cantidad ?? this.cantidad,
      precioBase: precioBase ?? this.precioBase,
      descuento: descuento ?? this.descuento,
      precio: precio ?? this.precio,
      fechaHoraInteraccion: fechaHoraInteraccion ?? this.fechaHoraInteraccion,
      fechaHoraCreacion: fechaHoraCreacion ?? this.fechaHoraCreacion,
      idEstado: idEstado ?? this.idEstado,
      descripcionEstado: descripcionEstado ?? this.descripcionEstado,
      idEstadoPadre: idEstadoPadre ?? this.idEstadoPadre,
      descripcionEstadoPadre:
          descripcionEstadoPadre ?? this.descripcionEstadoPadre,
      idCampania: idCampania ?? this.idCampania,
      nombreCampania: nombreCampania ?? this.nombreCampania,
      idOportunidad: idOportunidad ?? this.idOportunidad,
      nombreOportunidad: nombreOportunidad ?? this.nombreOportunidad,
      idCanal: idCanal ?? this.idCanal,
      descripcionCanal: descripcionCanal ?? this.descripcionCanal,
      idInteres: idInteres ?? this.idInteres,
      descripcionInteres: descripcionInteres ?? this.descripcionInteres,
      activo: activo ?? this.activo,
      idMoneda: idMoneda ?? this.idMoneda,
      totalLeadsNumero: totalLeadsNumero ?? this.totalLeadsNumero,
      idNumero: idNumero ?? this.idNumero,
      prefijoPais: prefijoPais ?? this.prefijoPais,
      numero: numero ?? this.numero,
      nombres: nombres ?? this.nombres,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      correo: correo ?? this.correo,
      ruc: ruc ?? this.ruc,
      numSol: numSol ?? this.numSol,
      idEstadoSol: idEstadoSol ?? this.idEstadoSol,
      idChatCab: idChatCab ?? this.idChatCab,
      fechaPrimerMensajeCliente:
          fechaPrimerMensajeCliente ?? this.fechaPrimerMensajeCliente,
    );
  }
}

extension NegociacionesX on List<Negociacion> {
  Negociacion? get primerLead {
    if (isEmpty) return null;
    final ordenadas = [...this]
      ..sort((a, b) => a.fechaHoraCreacion.compareTo(b.fechaHoraCreacion));
    return ordenadas.first;
  }

  /// La negociación con la actividad más reciente (por fecha de última
  /// interacción) — alimenta el campo "Última interacción".
  Negociacion? get ultimaInteraccion {
    if (isEmpty) return null;
    final ordenadas = [
      ...this,
    ]..sort((a, b) => b.fechaHoraInteraccion.compareTo(a.fechaHoraInteraccion));
    return ordenadas.first;
  }
}
