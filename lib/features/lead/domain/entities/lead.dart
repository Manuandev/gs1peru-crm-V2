// lib/features/lead/domain/entities/lead.dart
//
// Entidad unificada de lead — absorbe los campos de InfoLead (chat) y
// los campos propios del SP de seguimiento (leads list).
// Fuentes de datos:
//   - CSV_LEADS_LST_APP  (tasks LS y DT sección 1)  → LeadModel
//   - CSV_WHATSAPP_LST_APP (task D)                  → InfoLeadModel

import 'package:app_crm/index_dependencies.dart';

class Lead extends Equatable {
  // ── Identificadores ───────────────────────────────────────────
  final int    idLead;
  final int    idContacto;

  // ── Contacto ──────────────────────────────────────────────────
  final String  nombre;
  final String  apellido;
  final String  nombreEmpresa;
  final String  asesor;
  final String  fechaHora;

  // ── Número de contacto ────────────────────────────────────────
  final int    idNumero;
  final String prefijo;
  final String numero;
  final bool   isFavorito;

  // ── Correo ────────────────────────────────────────────────────
  final String correo;

  // ── Estado ────────────────────────────────────────────────────
  final String  idEstado;
  final String  estado;

  // ── Campaña / Oportunidad ─────────────────────────────────────
  final int    idCampania;
  final String campania;
  final int    idEvento;
  final String evento;

  // ── Canal / Interés ───────────────────────────────────────────
  final int    idCanal;
  final String canal;
  final int    idInteres;
  final String interes;

  // ── Conversación WhatsApp ─────────────────────────────────────
  // Indica si hay una conversación abierta asociada a este lead.
  final bool? tieneConversacionAbierta;

  // ── Campos adicionales del SP de chats ────────────────────────
  // Solo se poblán cuando el lead proviene del chat SP (task D).
  final String? nombreContacto;      // nombres + apellidoP + apellidoM concatenados
  final String? modalidad;
  final String? idEstadoPadre;
  final String? descripcionEstadoPadre;
  final String? idSubEstado;
  final String? subEstado;

  // ── Campos económicos ─────────────────────────────────────────
  final double? precioBase;
  final double? precio;
  // TODO: activar cuando columna exista en CRM.T_LEAD (el SP devuelve 0 hardcodeado)
  final double? cantidad;
  // TODO: activar cuando columna exista en CRM.T_LEAD (el SP devuelve 0 hardcodeado)
  final double? descuento;

  // ── Getters de conveniencia ───────────────────────────────────

  String get nombreCompleto => '$nombre $apellido'.trim();

  const Lead({
    required this.idLead,
    required this.idContacto,
    required this.nombre,
    required this.apellido,
    required this.nombreEmpresa,
    required this.asesor,
    required this.fechaHora,
    required this.idNumero,
    required this.prefijo,
    required this.numero,
    required this.isFavorito,
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
    this.modalidad,
    this.idEstadoPadre,
    this.descripcionEstadoPadre,
    this.idSubEstado,
    this.subEstado,
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
        apellido,
        nombreEmpresa,
        asesor,
        fechaHora,
        idNumero,
        prefijo,
        numero,
        isFavorito,
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
        modalidad,
        idEstadoPadre,
        descripcionEstadoPadre,
        idSubEstado,
        subEstado,
        precioBase,
        precio,
        cantidad,
        descuento,
      ];

  Lead copyWith({
    int?     idLead,
    int?     idContacto,
    String?  nombre,
    String?  apellido,
    String?  nombreEmpresa,
    String?  asesor,
    String?  fechaHora,
    int?     idNumero,
    String?  prefijo,
    String?  numero,
    bool?    isFavorito,
    String?  correo,
    String?  idEstado,
    String?  estado,
    int?     idCampania,
    String?  campania,
    int?     idEvento,
    String?  evento,
    bool     clearEvento = false,
    int?     idCanal,
    String?  canal,
    int?     idInteres,
    String?  interes,
    bool?    tieneConversacionAbierta,
    String?  nombreContacto,
    String?  modalidad,
    String?  idEstadoPadre,
    String?  descripcionEstadoPadre,
    String?  idSubEstado,
    String?  subEstado,
    double?  precioBase,
    double?  precio,
    double?  cantidad,
    double?  descuento,
  }) {
    return Lead(
      idLead:                   idLead          ?? this.idLead,
      idContacto:               idContacto      ?? this.idContacto,
      nombre:                   nombre          ?? this.nombre,
      apellido:                 apellido        ?? this.apellido,
      nombreEmpresa:            nombreEmpresa   ?? this.nombreEmpresa,
      asesor:                   asesor          ?? this.asesor,
      fechaHora:                fechaHora       ?? this.fechaHora,
      idNumero:                 idNumero        ?? this.idNumero,
      prefijo:                  prefijo         ?? this.prefijo,
      numero:                   numero          ?? this.numero,
      isFavorito:               isFavorito      ?? this.isFavorito,
      correo:                   correo          ?? this.correo,
      idEstado:                 idEstado        ?? this.idEstado,
      estado:                   estado          ?? this.estado,
      idCampania:               idCampania      ?? this.idCampania,
      campania:                 campania        ?? this.campania,
      idEvento:                 clearEvento ? 0 : (idEvento ?? this.idEvento),
      evento:                   clearEvento ? '' : (evento ?? this.evento),
      idCanal:                  idCanal         ?? this.idCanal,
      canal:                    canal           ?? this.canal,
      idInteres:                idInteres       ?? this.idInteres,
      interes:                  interes         ?? this.interes,
      tieneConversacionAbierta: tieneConversacionAbierta ?? this.tieneConversacionAbierta,
      nombreContacto:           nombreContacto  ?? this.nombreContacto,
      modalidad:                modalidad       ?? this.modalidad,
      idEstadoPadre:            idEstadoPadre   ?? this.idEstadoPadre,
      descripcionEstadoPadre:   descripcionEstadoPadre ?? this.descripcionEstadoPadre,
      idSubEstado:              idSubEstado     ?? this.idSubEstado,
      subEstado:                subEstado       ?? this.subEstado,
      precioBase:               precioBase      ?? this.precioBase,
      precio:                   precio          ?? this.precio,
      cantidad:                 cantidad        ?? this.cantidad,
      descuento:                descuento       ?? this.descuento,
    );
  }
}
