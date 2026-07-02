// lib/features/lead/domain/entities/contacto_detalle.dart

import 'package:app_crm/index_dependencies.dart';

class ContactoDetalle extends Equatable {
  final int idContacto;
  final String nombre;
  final String apellido;
  final String cargo;
  final String empresa;
  final String razonSocial;
  final String tipoDocumento;
  final String numDocumento;
  final String prefijo;
  final String numero;
  final String correo;
  final String fechaRegistro;
  final String direccion;
  final String departamento;
  final String provincia;
  final String distrito;

  String get nombreCompleto => '$nombre $apellido'.trim();
  String get telefonoCompleto => '$prefijo $numero'.trim();
  String get ubigeo => '$departamento / $provincia / $distrito';

  const ContactoDetalle({
    required this.idContacto,
    required this.nombre,
    required this.apellido,
    required this.cargo,
    required this.empresa,
    required this.razonSocial,
    required this.tipoDocumento,
    required this.numDocumento,
    required this.prefijo,
    required this.numero,
    required this.correo,
    required this.fechaRegistro,
    required this.direccion,
    required this.departamento,
    required this.provincia,
    required this.distrito,
  });

  @override
  List<Object?> get props => [
    idContacto,
    nombre,
    apellido,
    cargo,
    empresa,
    razonSocial,
    tipoDocumento,
    numDocumento,
    prefijo,
    numero,
    correo,
    fechaRegistro,
    direccion,
    departamento,
    provincia,
    distrito,
  ];
}
