// lib/features/lead/domain/entities/lead.dart
//
// Entidad unificada de lead.
// Fuentes de datos:
//   - CSV_LEADS_LST_APP  (tasks LS y DT sección 1)  → LeadModel
//   - CSV_WHATSAPP_LST_APP (task LS)                 → ChatModel + LeadModel

import 'package:app_crm/index_dependencies.dart';

class Lead extends Equatable {
  // ── Identificadores ───────────────────────────────────────────
  final int idLead;
  final int idContacto;

  // ── Contacto ──────────────────────────────────────────────────
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String nombreEmpresa;
  final String asesor;
  final String fechaHora;

  /// Fecha de creación real del lead (LD.FC_USUARIO_C) — distinta de
  /// [fechaHora], que es la fecha de última modificación o creación.
  final String? fechaCreacion;

  // ── Número de contacto ────────────────────────────────────────
  final int idNumero;
  final String prefijo;
  final String numero;
  final bool isFavorito;

  /// Id de la conversación (T_CONVERSACION_CAB) más reciente de este número —
  /// clave única para abrir ChatDetail sin importar desde dónde se navegue
  /// (lista de chats, lista de leads, home). 0 si el número nunca conversó.
  final int idChatCab;

  // ── Correo ────────────────────────────────────────────────────
  final String correo;

  // ── Estado ────────────────────────────────────────────────────
  final String idEstado;
  final String estado;

  // ── Campaña / Oportunidad ─────────────────────────────────────
  final int idCampania;
  final String campania;
  final int idEvento;
  final String evento;

  // ── Canal / Interés ───────────────────────────────────────────
  final int idCanal;
  final String canal;
  final int idInteres;
  final String interes;

  // ── Conversación WhatsApp ─────────────────────────────────────
  final bool? tieneConversacionAbierta;

  // ── Campos adicionales del SP de chats ────────────────────────
  final String? nombreContacto;
  final String? nombreLead;
  final String? modalidad;
  final String? idEstadoPadre;
  final String? descripcionEstadoPadre;
  final String? idSubEstado;
  final String? subEstado;
  final String? cargo;

  // ── Campos económicos ─────────────────────────────────────────
  final double? precioBase;
  final double? precio;
  final int? cantidad;
  final double? descuento;

  // ── Getters de conveniencia ───────────────────────────────────

  /// Apellidos combinados — compatible con código existente.
  String get apellido => '$apellidoPaterno $apellidoMaterno'.trim();

  /// Nombre completo del contacto. Si no tiene nombre/apellidos registrados,
  /// muestra el número de teléfono como identificador.
  String get nombreCompleto {
    final partes = [
      nombre,
      apellidoPaterno,
      apellidoMaterno,
    ].where((parte) => parte.trim().isNotEmpty).join(' ');
    return partes.isNotEmpty ? partes : '$prefijo $numero';
  }

  /// Id de estado a mostrar/agrupar: si el lead tiene un sub-estado
  /// (idEstadoPadre presente), se usa el padre — ej. "Con ficha" agrupa
  /// visualmente bajo "En desarrollo".
  String get idEstadoEfectivo =>
      (idEstadoPadre?.isNotEmpty ?? false) ? idEstadoPadre! : idEstado;

  /// Descripción de estado a mostrar — misma regla que [idEstadoEfectivo].
  String get estadoEfectivo => (idEstadoPadre?.isNotEmpty ?? false)
      ? (descripcionEstadoPadre?.isNotEmpty ?? false)
          ? descripcionEstadoPadre!
          : estado
      : estado;

  const Lead({
    required this.idLead,
    required this.idContacto,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.nombreEmpresa,
    required this.asesor,
    required this.fechaHora,
    this.fechaCreacion,
    required this.idNumero,
    required this.prefijo,
    required this.numero,
    required this.isFavorito,
    this.idChatCab = 0,
    required this.correo,
    required this.idEstado,
    required this.estado,
    required this.idCampania,
    required this.campania,
    required this.idEvento,
    required this.evento,
    required this.idCanal,
    required this.canal,
    required this.idInteres,
    required this.interes,
    this.tieneConversacionAbierta,
    this.nombreContacto,
    this.nombreLead,
    this.modalidad,
    this.idEstadoPadre,
    this.descripcionEstadoPadre,
    this.idSubEstado,
    this.subEstado,
    this.cargo,
    this.precioBase,
    this.precio,
    this.cantidad,
    this.descuento,
  });

  @override
  List<Object?> get props => [
    idLead,
    idContacto,
    nombre,
    apellidoPaterno,
    apellidoMaterno,
    nombreEmpresa,
    asesor,
    fechaHora,
    fechaCreacion,
    idNumero,
    prefijo,
    numero,
    isFavorito,
    idChatCab,
    correo,
    idEstado,
    estado,
    idCampania,
    campania,
    idEvento,
    evento,
    idCanal,
    canal,
    idInteres,
    interes,
    tieneConversacionAbierta,
    nombreContacto,
    nombreLead,
    modalidad,
    idEstadoPadre,
    descripcionEstadoPadre,
    idSubEstado,
    subEstado,
    cargo,
    precioBase,
    precio,
    cantidad,
    descuento,
  ];

  Lead copyWith({
    int? idLead,
    int? idContacto,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? nombreEmpresa,
    String? asesor,
    String? fechaHora,
    String? fechaCreacion,
    int? idNumero,
    String? prefijo,
    String? numero,
    bool? isFavorito,
    int? idChatCab,
    String? correo,
    String? idEstado,
    String? estado,
    int? idCampania,
    String? campania,
    int? idEvento,
    String? evento,
    bool clearEvento = false,
    int? idCanal,
    String? canal,
    int? idInteres,
    String? interes,
    bool? tieneConversacionAbierta,
    String? nombreContacto,
    String? nombreLead,
    String? modalidad,
    String? idEstadoPadre,
    bool clearEstadoPadre = false,
    String? descripcionEstadoPadre,
    String? idSubEstado,
    String? subEstado,
    String? cargo,
    double? precioBase,
    double? precio,
    int? cantidad,
    double? descuento,
  }) {
    return Lead(
      idLead: idLead ?? this.idLead,
      idContacto: idContacto ?? this.idContacto,
      nombre: nombre ?? this.nombre,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      asesor: asesor ?? this.asesor,
      fechaHora: fechaHora ?? this.fechaHora,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      idNumero: idNumero ?? this.idNumero,
      prefijo: prefijo ?? this.prefijo,
      numero: numero ?? this.numero,
      isFavorito: isFavorito ?? this.isFavorito,
      idChatCab: idChatCab ?? this.idChatCab,
      correo: correo ?? this.correo,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      idCampania: idCampania ?? this.idCampania,
      campania: campania ?? this.campania,
      idEvento: clearEvento ? 0 : (idEvento ?? this.idEvento),
      evento: clearEvento ? '' : (evento ?? this.evento),
      idCanal: idCanal ?? this.idCanal,
      canal: canal ?? this.canal,
      idInteres: idInteres ?? this.idInteres,
      interes: interes ?? this.interes,
      tieneConversacionAbierta:
          tieneConversacionAbierta ?? this.tieneConversacionAbierta,
      nombreContacto: nombreContacto ?? this.nombreContacto,
      nombreLead: nombreLead ?? this.nombreLead,
      modalidad: modalidad ?? this.modalidad,
      idEstadoPadre: clearEstadoPadre
          ? null
          : (idEstadoPadre ?? this.idEstadoPadre),
      descripcionEstadoPadre: clearEstadoPadre
          ? null
          : (descripcionEstadoPadre ?? this.descripcionEstadoPadre),
      idSubEstado: idSubEstado ?? this.idSubEstado,
      subEstado: subEstado ?? this.subEstado,
      cargo: cargo ?? this.cargo,
      precioBase: precioBase ?? this.precioBase,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
      descuento: descuento ?? this.descuento,
    );
  }
}
