// lib/features/home/domain/entities/asesor_home.dart

class AsesorHome {
  final String nombre;
  final int activas;
  final int nuevos;
  final int enDesarrollo;
  final bool enLinea;

  const AsesorHome({
    required this.nombre,
    required this.activas,
    required this.nuevos,
    required this.enDesarrollo,
    required this.enLinea,
  });
}
