// lib\features\chat\data\models\chat_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class InfoLeadModel extends InfoLead {
  const InfoLeadModel({
    required super.idLead,
    required super.cliente,
    required super.telefono,
    required super.isFavorito,
    required super.idEstado,
    required super.estado,
    required super.idSubEstado,
    required super.subEstado,
    required super.idCampania,
    required super.campania,
    required super.idEvento,
    required super.evento,
    required super.idCanal,
    required super.canal,
    required super.idInteres,
    required super.interes,
    required super.isBloqueado,
    required super.isExpirado,
    required super.isCerrado,
  });

  factory InfoLeadModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    final String canal = f(13);
    final String campania = f(9);
    final String evento = f(11);
    final String interes = f(15);

    return InfoLeadModel(
      idLead: int.parse(f(0)),
      cliente: f(1),
      telefono: f(2),
      isFavorito: f(3) == '1',
      idEstado: f(4),
      estado: f(5),
      idSubEstado: f(6),
      subEstado: f(7),
      idCampania: campania.isEmpty ? null : int.tryParse(f(8)),
      campania: campania.isEmpty ? null : campania,
      idEvento: evento.isEmpty ? null : int.tryParse(f(10)),
      evento: evento.isEmpty ? null : evento,
      idCanal: canal.isEmpty ? null : int.tryParse(f(12)),
      canal: canal.isEmpty ? null : canal,
      idInteres: interes.isEmpty ? null : int.tryParse(f(14)),
      interes: interes.isEmpty ? null : interes,
      isBloqueado: f(16) == '1',
      isExpirado: f(17) == '1',
      isCerrado: f(18) == '1',
    );
  }

  static InfoLeadModel parse(String rawResponse) {
    final raw = rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .first;

    return InfoLeadModel.fromRawString(raw);
  }
}
