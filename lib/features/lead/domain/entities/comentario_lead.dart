// lib/features/lead/domain/entities/comentario_lead.dart

class ComentarioLead {
  final int id;
  final String autor;
  final String texto;
  final String actividad;
  final String fechaHora;

  const ComentarioLead({
    required this.id,
    required this.autor,
    required this.texto,
    required this.actividad,
    required this.fechaHora,
  });
}
