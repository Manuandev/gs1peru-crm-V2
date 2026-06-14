// lib/features/home/domain/entities/prospecto_home.dart
class ProspectoHome {
  final int idLead;
  final String nombre;
  final String nombreEmpresa;
  final String fechaHora;

  const ProspectoHome({
    required this.idLead,
    required this.nombre,
    required this.nombreEmpresa,
    required this.fechaHora,
  });
}
