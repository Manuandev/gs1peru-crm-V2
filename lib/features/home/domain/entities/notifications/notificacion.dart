// lib/features/home/domain/entities/notifications/notificacion.dart

enum TipoNotificacion { actividad, derivacion, mensaje }

enum SubtipoNotificacion {
  // Actividades
  llamada,
  correo,
  whatsappActividad,
  actividadGenerica,
  // Derivaciones bot
  leadBot,
  prospectoDerivado,
  derivacionGenerica,
  // Mensajes
  mensajeWhatsapp,
  mensajeChat,
}

class Notificacion {
  final int id;
  final int idLead;
  final TipoNotificacion tipo;
  final SubtipoNotificacion subtipo;
  final String titulo;
  final String descripcion;
  final String fechaHora;
  final bool leido;

  const Notificacion({
    required this.id,
    required this.idLead,
    required this.tipo,
    required this.subtipo,
    required this.titulo,
    required this.descripcion,
    required this.fechaHora,
    required this.leido,
  });

  Notificacion copyWith({
    int? id,
    int? idLead,
    TipoNotificacion? tipo,
    SubtipoNotificacion? subtipo,
    String? titulo,
    String? descripcion,
    String? fechaHora,
    bool? leido,
  }) => Notificacion(
    id: id ?? this.id,
    idLead: idLead ?? this.idLead,
    tipo: tipo ?? this.tipo,
    subtipo: subtipo ?? this.subtipo,
    titulo: titulo ?? this.titulo,
    descripcion: descripcion ?? this.descripcion,
    fechaHora: fechaHora ?? this.fechaHora,
    leido: leido ?? this.leido,
  );

  // Etiqueta principal del chip según tipo
  String get etiquetaPrincipal => switch (tipo) {
    TipoNotificacion.actividad => 'Actividad',
    TipoNotificacion.derivacion => 'Derivación',
    TipoNotificacion.mensaje => 'Mensaje',
  };

  // Botón de acción: Actividad → Ver seguimiento | Derivacion/Mensaje → Ir al chat
  String get labelAccion => switch (tipo) {
    TipoNotificacion.actividad => 'Ver seguimiento',
    TipoNotificacion.derivacion => 'Ir al chat',
    TipoNotificacion.mensaje => 'Ir al chat',
  };

  // Las derivaciones del bot también muestran chip "Nuevo"
  bool get mostrarChipNuevo =>
      tipo == TipoNotificacion.derivacion &&
      (subtipo == SubtipoNotificacion.leadBot ||
          subtipo == SubtipoNotificacion.prospectoDerivado);
}
