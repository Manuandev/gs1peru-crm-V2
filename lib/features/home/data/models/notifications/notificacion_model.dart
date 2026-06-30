// lib/features/home/data/models/notifications/notificacion_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificacionModel extends Notificacion {
  const NotificacionModel({
    required super.id,
    required super.idLead,
    required super.tipo,
    required super.subtipo,
    required super.titulo,
    required super.descripcion,
    required super.fechaHora,
    required super.leido,
  });

  // Campos del SP (separados por ¦):
  // 0: id        — identificador único
  // 1: idLead    — id del lead asociado
  // 2: tipo      — 'A'=actividad | 'D'=derivacion | 'M'=mensaje
  // 3: subtipo   — ver _parseSubtipo
  // 4: titulo    — texto principal del item
  // 5: descripcion — texto secundario
  // 6: fechaHora — datetime "YYYY-MM-DD HH:mm:ss"
  // 7: leido     — '0'=no leído | '1'=leído
  factory NotificacionModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    
    return NotificacionModel(
      id: ParseUtils.toInt(c, 0),
      idLead: ParseUtils.toInt(c, 1),
      tipo: _parseTipo(ParseUtils.str(c, 2)),
      subtipo: _parseSubtipo(ParseUtils.str(c, 3)),
      titulo: ParseUtils.str(c, 4),
      descripcion: ParseUtils.str(c, 5),
      fechaHora: ParseUtils.str(c, 6),
      leido: ParseUtils.toBool(c, 7),
    );
  }

  static List<NotificacionModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => NotificacionModel.fromRawString(r))
        .toList();
  }

  static TipoNotificacion _parseTipo(String code) =>
      switch (code.toUpperCase()) {
        'A' => TipoNotificacion.actividad,
        'D' => TipoNotificacion.derivacion,
        'M' => TipoNotificacion.mensaje,
        _ => TipoNotificacion.actividad,
      };

  // Códigos de subtipo que el SP enviará
  static SubtipoNotificacion _parseSubtipo(String code) =>
      switch (code.toUpperCase()) {
        'LLAMADA' => SubtipoNotificacion.llamada,
        'CORREO' => SubtipoNotificacion.correo,
        'WHATSAPP_A' => SubtipoNotificacion.whatsappActividad,
        'ACTIVIDAD' => SubtipoNotificacion.actividadGenerica,
        'LEAD_BOT' => SubtipoNotificacion.leadBot,
        'PROSPECTO' => SubtipoNotificacion.prospectoDerivado,
        'DERIV' => SubtipoNotificacion.derivacionGenerica,
        'WHATSAPP_M' => SubtipoNotificacion.mensajeWhatsapp,
        'CHAT' => SubtipoNotificacion.mensajeChat,
        _ => SubtipoNotificacion.actividadGenerica,
      };
}
