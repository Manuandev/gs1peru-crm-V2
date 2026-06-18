// lib/features/lead/data/models/contacto_detalle_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetalleModel extends ContactoDetalle {
  const ContactoDetalleModel({
    required super.idContacto,
    required super.nombre,
    required super.apellido,
    required super.cargo,
    required super.empresa,
    required super.tipoDocumento,
    required super.numDocumento,
    required super.prefijo,
    required super.numero,
    required super.correo,
    required super.fechaRegistro,
    required super.direccion,
    required super.departamento,
    required super.provincia,
    required super.distrito,
  });

  // TODO: reemplazar por parseo real del SP cuando se defina la respuesta
  factory ContactoDetalleModel.fromRawString(String raw) {
    final fields = ParseUtils.campos(raw, AppConstants.sepCampos);
    return ContactoDetalleModel(
      idContacto: ParseUtils.toInt(fields, 0),
      nombre: ParseUtils.str(fields, 1),
      apellido: ParseUtils.str(fields, 2),
      cargo: ParseUtils.str(fields, 3),
      empresa: ParseUtils.str(fields, 4),
      tipoDocumento: ParseUtils.str(fields, 5),
      numDocumento: ParseUtils.str(fields, 6),
      prefijo: ParseUtils.str(fields, 7),
      numero: ParseUtils.str(fields, 8),
      correo: ParseUtils.str(fields, 9),
      fechaRegistro: ParseUtils.str(fields, 10),
      direccion: ParseUtils.str(fields, 11),
      departamento: ParseUtils.str(fields, 12),
      provincia: ParseUtils.str(fields, 13),
      distrito: ParseUtils.str(fields, 14),
    );
  }
}
