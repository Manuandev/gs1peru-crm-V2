// lib/features/chat/data/models/info_lead_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class InfoLeadModel extends InfoLead {
  const InfoLeadModel({
    required super.idLead,
    required super.nombre,
    required super.apellido,
    required super.nombreEmpresa,
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

    final String campania = f(11);
    final String evento = f(13);
    final String canal = f(15);
    final String interes = f(17);

    return InfoLeadModel(
      idLead: int.parse(f(0)),
      nombre: f(1),
      apellido: f(2),
      nombreEmpresa: f(3),
      telefono: f(4),
      isFavorito: f(5) == '1',
      idEstado: f(6),
      estado: f(7),
      idSubEstado: f(8),
      subEstado: f(9),
      idCampania: campania.isEmpty ? null : int.tryParse(f(10)),
      campania: campania.isEmpty ? null : campania,
      idEvento: evento.isEmpty ? null : int.tryParse(f(12)),
      evento: evento.isEmpty ? null : evento,
      idCanal: canal.isEmpty ? null : int.tryParse(f(14)),
      canal: canal.isEmpty ? null : canal,
      idInteres: interes.isEmpty ? null : int.tryParse(f(16)),
      interes: interes.isEmpty ? null : interes,
      isBloqueado: f(18) == '1',
      isExpirado: f(19) == '1',
      isCerrado: f(20) == '1',
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
