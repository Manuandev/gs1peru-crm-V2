// lib/features/home/domain/entities/prioridad_home.dart
class PrioridadHome {
  final int idLead;
  final String nombre;
  final String telefono;
  final String idEstado;
  final String estado;
  final int idCanal;
  final String canal;
  final String fechaHora;

  const PrioridadHome({
    required this.idLead,
    required this.nombre,
    required this.telefono,
    required this.idEstado,
    required this.estado,
    required this.idCanal,
    required this.canal,
    required this.fechaHora,
  });
}
