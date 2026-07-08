// lib/features/lead/data/models/contacto_negociacion_model.dart
//
// Parsea la respuesta del SP de listado (lead_list_page.dart, task 'LS').
// 'LS' comparte exactamente el mismo layout de columnas que 'DT' (mismo
// SELECT de [CRM].[CSV_LEADS_LST_APP], solo cambia el WHERE) — cada fila es
// 1 lead con su Contacto/Numero. Ya no trae un CL.CT_LEADS agregado por
// número — totalLeads queda en 0 (no se muestra en ningún widget hoy).
// Ver comentario de índices en NegociacionModel.fromDetalleRawString.

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
        // 00 → LD.ID_LEAD
        idLead: ParseUtils.toInt(fields, 0),
        nombre: '',
        modalidad: '',
        // 28 → LD.IN_PARTICIPANTES (cantidad)
        cantidad: ParseUtils.toInt(fields, 28),
        // 26 → LD.DC_PRECIO_BASE
        precioBase: ParseUtils.toDouble(fields, 26),
        // 29 → LD.DC_DESCUENTO
        descuento: ParseUtils.toDouble(fields, 29),
        // 27 → LD.DC_PRECIO
        precio: ParseUtils.toDouble(fields, 27),
        // 07 → FC_USUARIO_M ?? FC_USUARIO_C (última interacción)
        fechaHoraInteraccion: ParseUtils.str(fields, 7),
        // 30 → LD.FC_USUARIO_C (creación real)
        fechaHoraCreacion: ParseUtils.str(fields, 30),
        // 13 → LE.ID_ESTADO
        idEstado: ParseUtils.str(fields, 13),
        // 14 → LE.DESCRIPCION
        descripcionEstado: ParseUtils.str(fields, 14),
        // 15 → EP.ID_ESTADO (estado padre)
        idEstadoPadre: ParseUtils.str(fields, 15),
        // 16 → EP.DESCRIPCION (descripcion estado padre)
        descripcionEstadoPadre: ParseUtils.str(fields, 16),
        // 17 → CP.ID_CAMPANIA
        idCampania: ParseUtils.toInt(fields, 17),
        // 18 → CP.NOMBRE
        nombreCampania: ParseUtils.str(fields, 18),
        // 19 → OP.ID_OPORTUNIDAD
        idOportunidad: ParseUtils.toInt(fields, 19),
        // 20 → OP.NOMBRE
        nombreOportunidad: ParseUtils.str(fields, 20),
        // 21 → CN.ID_CANAL
        idCanal: ParseUtils.toInt(fields, 21),
        // 22 → CN.NOMBRE
        descripcionCanal: ParseUtils.str(fields, 22),
        // 23 → IT.ID_INTERES
        idInteres: ParseUtils.toInt(fields, 23),
        // 24 → IT.DESCRIPCION
        descripcionInteres: ParseUtils.str(fields, 24),
        // Sin columna propia de "activo" en este SP.
        activo: true,
        // 33 → LD.ID_TIP_MONEDA
        idMoneda: ParseUtils.str(fields, 33),
      ),
      // El SP ya no agrega CL.CT_LEADS — sin fuente hoy, y el campo no se
      // consume en ningún widget todavía.
      totalLeads: 0,
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
