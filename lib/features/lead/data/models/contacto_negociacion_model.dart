// lib/features/lead/data/models/contacto_negociacion_model.dart
//
// Parsea la respuesta del SP de listado (lead_list_page.dart, task 'LS').
// Cada fila trae 1 Contacto + su Numero + el lead más reciente de ese
// número (Negociacion) + el total de leads de ese número. No trae idLead,
// nombre/modalidad ni económicos — la card no los necesita (navega al
// detalle por idNumero, no por idLead) — quedan en su valor por defecto.

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoNegociacionModel extends ContactoNegociacion {
  const ContactoNegociacionModel({
    required super.contacto,
    required super.numero,
    required super.negociacion,
    required super.totalLeads,
  });

  factory ContactoNegociacionModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return ContactoNegociacionModel(
      contacto: ContactoModel.fromFields(fields),
      numero: NumeroModel.fromFields(fields),
      negociacion: Negociacion(
        // Sin columna propia en este SP — la card navega por idNumero, no
        // por idLead.
        idLead: 0,
        nombre: '',
        modalidad: '',
        cantidad: 0,
        precioBase: 0,
        descuento: 0,
        precio: 0,
        // 06 → FC_USUARIO_M ?? FC_USUARIO_C (última interacción)
        fechaHoraInteraccion: ParseUtils.str(fields, 6),
        // 07 → LD.FC_USUARIO_C (creación real)
        fechaHoraCreacion: ParseUtils.str(fields, 7),
        // 10 → LE.ID_ESTADO
        idEstado: ParseUtils.str(fields, 10),
        // 11 → LE.DESCRIPCION
        descripcionEstado: ParseUtils.str(fields, 11),
        // 12 → EP.ID_ESTADO (estado padre)
        idEstadoPadre: ParseUtils.str(fields, 12),
        // 13 → EP.DESCRIPCION (descripcion estado padre)
        descripcionEstadoPadre: ParseUtils.str(fields, 13),
        // 14 → CP.ID_CAMPANIA
        idCampania: ParseUtils.toInt(fields, 14),
        // 15 → CP.NOMBRE
        nombreCampania: ParseUtils.str(fields, 15),
        // 16 → OP.ID_OPORTUNIDAD
        idOportunidad: ParseUtils.toInt(fields, 16),
        // 17 → OP.NOMBRE
        nombreOportunidad: ParseUtils.str(fields, 17),
        // 18 → CN.ID_CANAL
        idCanal: ParseUtils.toInt(fields, 18),
        // 19 → CN.NOMBRE
        descripcionCanal: ParseUtils.str(fields, 19),
        // 20 → IT.ID_INTERES
        idInteres: ParseUtils.toInt(fields, 20),
        // 21 → IT.DESCRIPCION
        descripcionInteres: ParseUtils.str(fields, 21),
        // Sin columna propia de "activo" en este SP.
        activo: true,
      ),
      // 22 → CL.CT_LEADS
      totalLeads: ParseUtils.toInt(fields, 22),
    );
  }

  static List<ContactoNegociacionModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ContactoNegociacionModel.fromRawString(r))
        .toList();
  }

  static ContactoNegociacionModel? parse(String rawResponse) {
    if (rawResponse.trim().isEmpty) return null;
    return ContactoNegociacionModel.fromRawString(rawResponse);
  }
}
