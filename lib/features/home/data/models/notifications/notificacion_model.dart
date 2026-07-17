// lib/features/home/data/models/notifications/notificacion_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificacionModel extends Notificacion {
  const NotificacionModel({
    required super.id,
    required super.idLead,
    required super.tipo,
    required super.titulo,
    required super.descripcion,
    required super.fechaHora,
    required super.leido,
  });

  // Campos del SP CSV_NOTIFICACIONES_LST_APP (separados por ¦):
  // 0: ID_NOTIFICACION
  // 1: ID_REFERENCIA        — id del lead asociado
  // 2: ID_TIPO_NOTIFICACION — no se usa directo, el tipo sale de CODIGO (campo 7)
  // 3: TITULO
  // 4: DATOS                — texto libre, se usa como descripción/subtítulo
  // 5: IB_LEIDO
  // 6: NOMBRE (T_NOTIFICACION_TIPO) — no se usa en la UI por ahora
  // 7: CODIGO (T_NOTIFICACION_TIPO) — define el tipo (ver _parseTipo)
  // 8: FC_USUARIO_C         — fecha de creación (pendiente de confirmar en el SP)
  factory NotificacionModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);

    return NotificacionModel(
      id: ParseUtils.toInt(c, 0),
      idLead: ParseUtils.toInt(c, 1),
      tipo: _parseTipo(ParseUtils.str(c, 7)),
      titulo: ParseUtils.str(c, 3),
      descripcion: ParseUtils.str(c, 4),
      fechaHora: ParseUtils.str(c, 8),
      leido: ParseUtils.toBool(c, 5),
    );
  }

  static List<NotificacionModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => NotificacionModel.fromRawString(r))
        .toList();
  }

  // Agrupación real por T_NOTIFICACION_TIPO.CODIGO — todo lo que no sea
  // derivación de bot (AIA) o chat (CHAT) se considera actividad/negociación
  // (GESTION_DE_CODIGO, GESTION_DE_PAGO, INSCRIPCION_DE_EMPRESAS, y futuros).
  static TipoNotificacion _parseTipo(String codigo) =>
      switch (codigo.toUpperCase()) {
        'AIA' => TipoNotificacion.derivacion,
        'CHAT' => TipoNotificacion.mensaje,
        _ => TipoNotificacion.actividad,
      };
}
