// lib/features/home/domain/entities/notifications/notificacion.dart

import 'package:app_crm/core/utils/string/string_utils.dart';

enum TipoNotificacion {
  actividad,
  derivacion,
  mensaje,
  recordatorio,
  leadPorContactar,
  leadReasignado,
}

class Notificacion {
  final int id;
  final int idLead;
  final TipoNotificacion tipo;
  final String titulo;
  final String descripcion;
  final String fechaHora;
  final bool leido;
  // Solo presente en derivación/mensaje (viene dentro de DATOS) — null en actividad.
  final int? idChatCab;
  // Solo presente en leadPorContactar/leadReasignado (viene dentro de DATOS,
  // ver notificacion_model.dart) — null en el resto de tipos. Usado por
  // "Ver seguimiento" para ir a detalle de contacto (T_LEAD.ID_CONTACTO).
  final int? idContacto;
  // Solo presente en derivación/mensaje — reemplaza a etiquetaPrincipal en el
  // chip inferior de la tarjeta (ver getter abajo). Vacío en el resto de tipos.
  final String oportunidad;

  const Notificacion({
    required this.id,
    required this.idLead,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.fechaHora,
    required this.leido,
    this.idChatCab,
    this.idContacto,
    this.oportunidad = '',
  });

  Notificacion copyWith({
    int? id,
    int? idLead,
    TipoNotificacion? tipo,
    String? titulo,
    String? descripcion,
    String? fechaHora,
    bool? leido,
    int? idChatCab,
    int? idContacto,
    String? oportunidad,
  }) => Notificacion(
    id: id ?? this.id,
    idLead: idLead ?? this.idLead,
    tipo: tipo ?? this.tipo,
    titulo: titulo ?? this.titulo,
    descripcion: descripcion ?? this.descripcion,
    fechaHora: fechaHora ?? this.fechaHora,
    leido: leido ?? this.leido,
    idChatCab: idChatCab ?? this.idChatCab,
    idContacto: idContacto ?? this.idContacto,
    oportunidad: oportunidad ?? this.oportunidad,
  );

  // Etiqueta principal del chip según tipo — mensaje/derivación muestran la
  // oportunidad en vez del tipo (pedido de negocio, 2026-08-13).
  String get etiquetaPrincipal {
    if ((tipo == TipoNotificacion.mensaje ||
            tipo == TipoNotificacion.derivacion) &&
        oportunidad.isNotEmpty) {
      return oportunidad.aTitulo;
    }
    return switch (tipo) {
      TipoNotificacion.actividad => 'Actividad',
      TipoNotificacion.derivacion => 'Derivación',
      TipoNotificacion.mensaje => 'Mensaje',
      TipoNotificacion.recordatorio => 'Recordatorio',
      TipoNotificacion.leadPorContactar => 'Por contactar',
      TipoNotificacion.leadReasignado => 'Reasignado',
    };
  }

  // Botón de acción: Derivación/Mensaje → Ver conversación | el resto → Ver seguimiento
  String get labelAccion => switch (tipo) {
    TipoNotificacion.derivacion => 'Ver conversación',
    TipoNotificacion.mensaje => 'Ver conversación',
    TipoNotificacion.actividad ||
    TipoNotificacion.recordatorio ||
    TipoNotificacion.leadPorContactar ||
    TipoNotificacion.leadReasignado => 'Ver seguimiento',
  };

  // Las derivaciones del bot muestran chip "Nuevo"
  bool get mostrarChipNuevo => tipo == TipoNotificacion.derivacion;
}
