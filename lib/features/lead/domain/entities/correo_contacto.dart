// lib/features/lead/domain/entities/correo_contacto.dart
//
// Correo editable de un contacto (T_CONTACTO_CORREO).

import 'package:app_crm/index_dependencies.dart';

class CorreoContacto extends Equatable {
  final int idCorreo;
  final String correo;
  final bool activo;

  const CorreoContacto({
    this.idCorreo = 0,
    this.correo = '',
    this.activo = true,
  });

  CorreoContacto copyWith({int? idCorreo, String? correo, bool? activo}) {
    return CorreoContacto(
      idCorreo: idCorreo ?? this.idCorreo,
      correo: correo ?? this.correo,
      activo: activo ?? this.activo,
    );
  }

  @override
  List<Object?> get props => [idCorreo, correo, activo];
}
