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
    super.idChatCab,
  });

  // Campos del SP CSV_NOTIFICACIONES_LST_APP (separados por ¦):
  // 0: ID_NOTIFICACION
  // 1: ID_REFERENCIA        — id del lead asociado
  // 2: ID_TIPO_NOTIFICACION — no se usa directo, el tipo sale de CODIGO
  // 3: TITULO
  // 4: DATOS                — armado desde el INSERT, usa ¦ como separador
  //                           interno también, así que puede traer más ¦ de
  //                           los que le tocan (ver reconstrucción abajo)
  // ...: IB_LEIDO, NOMBRE, CODIGO, FC_USUARIO_C — últimos 4 campos fijos
  factory NotificacionModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    final n = c.length;

    // DATOS (campo 4) usa el mismo separador ¦ como interno, así que no se
    // puede tomar como un campo más — se reconstruye con todo lo que sobra
    // entre los 4 campos fijos del inicio (0-3) y los 4 fijos del final
    // (IB_LEIDO, NOMBRE, CODIGO, FC_USUARIO_C).
    final datosRaw = n > 8
        ? c.sublist(4, n - 4).join(AppConstants.sepCampos)
        : ParseUtils.str(c, 4);

    final tipo = _parseTipo(ParseUtils.str(c, n - 2));

    var descripcion = datosRaw;
    int? idChatCab;

    if (tipo == TipoNotificacion.mensaje || tipo == TipoNotificacion.derivacion) {
      final (desc, chatCab) = _parseDatosChat(tipo, datosRaw);
      descripcion = desc;
      idChatCab = chatCab;
    }

    return NotificacionModel(
      id: ParseUtils.toInt(c, 0),
      idLead: ParseUtils.toInt(c, 1),
      tipo: tipo,
      titulo: ParseUtils.str(c, 3),
      descripcion: descripcion,
      fechaHora: ParseUtils.str(c, n - 1),
      leido: ParseUtils.toBool(c, n - 4),
      idChatCab: idChatCab,
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

  // DATOS para mensaje/derivación (ejemplo real confirmado):
  // "Manuel Antonio Cardenas Valente¦Curso Digital Procurement¦Nuevo mensaje"
  //   0: nombre cliente  1: oportunidad  2: título
  //   3: idChatCab  4: idNumero — PENDIENTE de confirmar con un ejemplo que los traiga
  static (String, int?) _parseDatosChat(TipoNotificacion tipo, String datosRaw) {
    final d = ParseUtils.campos(datosRaw, AppConstants.sepCampos);
    final nombreCliente = ParseUtils.str(d, 0);
    final oportunidad = ParseUtils.str(d, 1);
    final idChatCab = int.tryParse(ParseUtils.str(d, 3));

    final descripcion = tipo == TipoNotificacion.mensaje
        ? '$nombreCliente de la oportunidad $oportunidad te ha enviado un mensaje.'
        : 'Se te ha derivado a $nombreCliente interesado en $oportunidad.';

    return (descripcion, idChatCab);
  }
}
