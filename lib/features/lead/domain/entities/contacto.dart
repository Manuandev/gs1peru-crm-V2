// lib/features/lead/domain/entities/contacto.dart
//
// Identidad pura del contacto (T_CONTACTO) — sin datos de número ni de
// negociación. Ver [Numero] para el canal/estado y [Negociacion] para el
// lead. El composite [ContactoNegociacion] junta los tres para el listado.

import 'package:app_crm/index_dependencies.dart';

class Contacto extends Equatable {
  final int idContacto;

  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String nombreEmpresa;
  final String asesor;
  final String? cargo;

  final String? correo;

  /// Apellidos combinados.
  String get apellido => '$apellidoPaterno $apellidoMaterno'.trim();

  /// Nombre completo del contacto — vacío si no tiene nombre/apellidos
  /// registrados (el fallback a número de teléfono vive en [ContactoNegociacion],
  /// que sí conoce el [Numero]).
  String get nombreCompleto =>
      [nombre, apellidoPaterno, apellidoMaterno]
          .where((parte) => parte.trim().isNotEmpty)
          .join(' ');

  const Contacto({
    required this.idContacto,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.nombreEmpresa,
    required this.asesor,
    this.cargo,
    this.correo,
  });

  @override
  List<Object?> get props => [
    idContacto,
    nombre,
    apellidoPaterno,
    apellidoMaterno,
    nombreEmpresa,
    asesor,
    cargo,
    correo,
  ];

  Contacto copyWith({
    int? idContacto,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? nombreEmpresa,
    String? asesor,
    String? cargo,
    String? correo,
  }) {
    return Contacto(
      idContacto: idContacto ?? this.idContacto,
      nombre: nombre ?? this.nombre,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      asesor: asesor ?? this.asesor,
      cargo: cargo ?? this.cargo,
      correo: correo ?? this.correo,
    );
  }
}
