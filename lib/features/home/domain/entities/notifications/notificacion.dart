// lib/features/home/domain/entities/notifications/notificacion.dart

enum TipoNotificacion { actividad, derivacion, mensaje }

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

  const Notificacion({
    required this.id,
    required this.idLead,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.fechaHora,
    required this.leido,
    this.idChatCab,
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
  }) => Notificacion(
    id: id ?? this.id,
    idLead: idLead ?? this.idLead,
    tipo: tipo ?? this.tipo,
    titulo: titulo ?? this.titulo,
    descripcion: descripcion ?? this.descripcion,
    fechaHora: fechaHora ?? this.fechaHora,
    leido: leido ?? this.leido,
    idChatCab: idChatCab ?? this.idChatCab,
  );

  // Etiqueta principal del chip según tipo
  String get etiquetaPrincipal => switch (tipo) {
    TipoNotificacion.actividad => 'Actividad',
    TipoNotificacion.derivacion => 'Derivación',
    TipoNotificacion.mensaje => 'Mensaje',
  };

  // Botón de acción: Actividad → Ver seguimiento | Derivación/Mensaje → Ver conversación
  String get labelAccion => switch (tipo) {
    TipoNotificacion.actividad => 'Ver seguimiento',
    TipoNotificacion.derivacion => 'Ver conversación',
    TipoNotificacion.mensaje => 'Ver conversación',
  };

  // Las derivaciones del bot muestran chip "Nuevo"
  bool get mostrarChipNuevo => tipo == TipoNotificacion.derivacion;
}
