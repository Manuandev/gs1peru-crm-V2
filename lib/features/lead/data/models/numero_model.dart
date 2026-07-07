// lib/features/lead/data/models/numero_model.dart
//
// Parsea la porción de Numero (T_NUMERO + conversación) de la fila del SP de
// listado (lead_list_page.dart, task 'LS'). Se usa desde
// ContactoNegociacionModel, que reparte los mismos campos entre
// Contacto/Numero/Negociacion.
// prefijo/numero/favorito no vienen en este SP (la card no los muestra) —
// quedan en su valor por defecto.

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class NumeroModel extends Numero {
  const NumeroModel({
    required super.idNumero,
    super.prefijo,
    super.numero,
    super.isFavorito,
    super.idChatCab,
    super.tieneConversacionAbierta,
  });

  factory NumeroModel.fromFields(List<String> fields) {
    return NumeroModel(
      // 08 → NM.ID_NUMERO
      idNumero: ParseUtils.toInt(fields, 8),
      // 09 → CC.ID_CONVERSACION_CAB (conversación más reciente del número)
      idChatCab: ParseUtils.toInt(fields, 9),
    );
  }
}
