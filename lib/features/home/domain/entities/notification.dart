// lib/features/home/domain/entities/notification.dart

class Notification {
  final int idLead;
  final String nombre;
  final String telefono;
  final String oportunidad;
  final String fechaHora;

  const Notification({
    required this.idLead,
    required this.nombre,
    required this.telefono,
    required this.oportunidad,
    required this.fechaHora,
  });
}
