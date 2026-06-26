// lib/features/home/domain/entities/prioridad_home.dart
class PrioridadHome {
  final int idNumero;
  final int idLead;
  final String nombre;
  final String telefono;
  final String idEstado;
  final String estado;
  final int idCanal;
  final String canal;
  final String fechaHora;
  final String prefijoTelefono;

  const PrioridadHome({
    required this.idNumero,
    required this.idLead,
    required this.nombre,
    required this.telefono,
    required this.idEstado,
    required this.estado,
    required this.idCanal,
    required this.canal,
    required this.fechaHora,
    required this.prefijoTelefono,
  });

  String get telefonoCompleto => "$prefijoTelefono $telefono";

  List<Object?> get props => [
    idNumero,
    idLead,
    nombre,
    telefono,
    idEstado,
    estado,
    idCanal,
    canal,
    fechaHora,
    prefijoTelefono,
  ];

  PrioridadHome copyWith({
    int? idNumero,
    int? idLead,
    String? nombre,
    String? telefono,
    String? idEstado,
    String? estado,
    int? idCanal,
    String? canal,
    String? fechaHora,
    String? prefijoTelefono,
  }) {
    return PrioridadHome(
      idNumero: idNumero ?? this.idNumero,
      idLead: idLead ?? this.idLead,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      idCanal: idCanal ?? this.idCanal,
      canal: canal ?? this.canal,
      fechaHora: fechaHora ?? this.fechaHora,
      prefijoTelefono: prefijoTelefono ?? this.prefijoTelefono,
    );
  }
}
