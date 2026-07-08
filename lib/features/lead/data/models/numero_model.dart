// lib/features/lead/data/models/numero_model.dart
//
// Parsea la porción de Numero (T_NUMERO + conversación) de la fila del SP de
// listado (lead_list_page.dart, task 'LS'). Se usa desde
// ContactoNegociacionModel, que reparte los mismos campos entre
// Contacto/Numero/Negociacion.
// 'LS' comparte exactamente el mismo layout de columnas que 'DT' — ver
// comentario de índices en NegociacionModel.fromDetalleRawString.

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
      // 09 → NM.PREFIJO_PAIS
      prefijo: ParseUtils.str(fields, 9),
      // 10 → NM.NUMERO
      numero: ParseUtils.str(fields, 10),
      // 11 → NM.IB_FAVORITO
      isFavorito: ParseUtils.toBool(fields, 11),
      // 25 → CASE WHEN CC.ID_NUMERO IS NOT NULL THEN 1 ELSE 0 END (abierta)
      tieneConversacionAbierta: ParseUtils.toBool(fields, 25),
      // 31 → CCU.ID_CONVERSACION_CAB (conversación más reciente del número)
      idChatCab: ParseUtils.toInt(fields, 31),
    );
  }
}
