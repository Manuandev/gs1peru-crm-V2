// lib/features/lead/domain/entities/comentario_lead.dart

class ComentarioLead {
  final int id;
  final String texto;
  final String fechaHora;
  final String autor;

  const ComentarioLead({
    required this.id,
    required this.texto,
    required this.fechaHora,
    required this.autor,
  });
}
