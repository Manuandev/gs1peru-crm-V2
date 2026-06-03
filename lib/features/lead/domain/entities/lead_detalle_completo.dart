// lib/features/lead/domain/entities/lead_detalle_completo.dart

class LeadDetalleCompleto {
  final int idLead;
  final String nombre;
  final String apellido;
  final String nombreEmpresa;
  final String telefono;
  final String correo;
  final int idCanal;
  final String canal;
  final String? interes;
  final String idEstado;
  final String estado;
  final String fechaUltimaInteraccion;

  String get nombreCompleto => '$nombre $apellido'.trim();

  const LeadDetalleCompleto({
    required this.idLead,
    required this.nombre,
    required this.apellido,
    required this.nombreEmpresa,
    required this.telefono,
    required this.correo,
    required this.idCanal,
    required this.canal,
    required this.interes,
    required this.idEstado,
    required this.estado,
    required this.fechaUltimaInteraccion,
  });
}
