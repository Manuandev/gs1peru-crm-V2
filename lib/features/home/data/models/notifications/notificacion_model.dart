// lib/features/home/data/models/notifications/notificacion_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificacionModel extends Notificacion {
  // Solo se llenan en mensaje/derivación — nombreCliente/codUserDestinatario
  // se usan para reconstruir el texto cuando varios mensajes del mismo chat
  // se agrupan en _agruparMensajes. oportunidad sí viaja en la entidad base
  // (Notificacion) porque la UI la necesita para el chip.
  final String nombreCliente;
  // CODUSER crudo del destinatario (NT.ID_USUARIO tal cual, sin join a
  // nombre) — vacío si el campo no vino en el CSV.
  final String codUserDestinatario;

  const NotificacionModel({
    required super.id,
    required super.idLead,
    required super.tipo,
    required super.titulo,
    required super.descripcion,
    required super.fechaHora,
    required super.leido,
    super.idChatCab,
    super.oportunidad,
    this.nombreCliente = '',
    this.codUserDestinatario = '',
  });

  // Campos del SP CSV_NOTIFICACIONES_LST_APP (separados por ¦):
  // 0: ID_NOTIFICACION
  // 1: ID_REFERENCIA        — id del lead asociado
  // 2: ID_TIPO_NOTIFICACION — no se usa directo, el tipo sale de CODIGO
  // 3: TITULO
  // 4: DATOS                — armado desde el INSERT, usa ¦ como separador
  //                           interno también, así que puede traer más ¦ de
  //                           los que le tocan (ver reconstrucción abajo)
  // ...: IB_LEIDO, NOMBRE, CODIGO, FC_USUARIO_C, ID_USUARIO — últimos 5
  //      campos fijos. El último (agregado 2026-08-13) es NT.ID_USUARIO tal
  //      cual (CODUSER del destinatario, sin join a nombre — decisión del
  //      usuario, ver nota en _parseDatosChat) — se compara contra el
  //      CODUSER logueado para decidir si el texto usa "te" o nombra al
  //      destinatario por su código.
  factory NotificacionModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    final n = c.length;

    // DATOS (campo 4) usa el mismo separador ¦ como interno, así que no se
    // puede tomar como un campo más — se reconstruye con todo lo que sobra
    // entre los 4 campos fijos del inicio (0-3) y los 5 fijos del final
    // (IB_LEIDO, NOMBRE, CODIGO, FC_USUARIO_C, ID_USUARIO).
    final datosRaw = n > 9
        ? c.sublist(4, n - 5).join(AppConstants.sepCampos)
        : ParseUtils.str(c, 4);

    final tipo = _parseTipo(ParseUtils.str(c, n - 3));
    final codUserDestinatario = ParseUtils.str(c, n - 1);

    var descripcion = datosRaw;
    int? idChatCab;
    var nombreCliente = '';
    var oportunidad = '';

    if (tipo == TipoNotificacion.mensaje ||
        tipo == TipoNotificacion.derivacion) {
      final (desc, chatCab, nombre, oport) = _parseDatosChat(
        tipo,
        datosRaw,
        codUserDestinatario,
      );
      descripcion = desc;
      idChatCab = chatCab;
      nombreCliente = nombre;
      oportunidad = oport;
    } else if (tipo == TipoNotificacion.recordatorio) {
      descripcion = _parseDatosRecordatorio(datosRaw);
    } else if (tipo == TipoNotificacion.leadPorContactar) {
      descripcion = _parseDatosLeadPorContactar(datosRaw);
    } else if (tipo == TipoNotificacion.leadReasignado) {
      descripcion = _parseDatosLeadReasignado(datosRaw);
    }

    return NotificacionModel(
      id: ParseUtils.toInt(c, 0),
      idLead: ParseUtils.toInt(c, 1),
      tipo: tipo,
      titulo: ParseUtils.str(c, 3),
      descripcion: descripcion,
      fechaHora: ParseUtils.str(c, n - 2),
      leido: ParseUtils.toBool(c, n - 5),
      idChatCab: idChatCab,
      oportunidad: oportunidad,
      nombreCliente: nombreCliente,
      codUserDestinatario: codUserDestinatario,
    );
  }

  // true si el destinatario de la notificación es el usuario logueado —
  // en ese caso el texto usa "te" en vez de nombrar el CODUSER destinatario.
  static bool _esPropio(String codUserDestinatario) =>
      codUserDestinatario.trim().toUpperCase() ==
      SessionService().codUser.trim().toUpperCase();

  static List<Notificacion> parseList(String rawResponse) {
    final notificaciones = rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => NotificacionModel.fromRawString(r))
        .toList();

    return _agruparMensajes(notificaciones);
  }

  // Cada mensaje de WhatsApp genera su propia fila en T_NOTIFICACION (ver
  // CSV_WHATSAPP_CHAT_CUD_SP_V03) — si el cliente manda varios seguidos,
  // llegan varias notificaciones para el mismo idChatCab. Acá se colapsan en
  // una sola tarjeta usando los datos del mensaje más reciente + el total
  // agrupado, para no inundar la lista ni desplazar otras notificaciones.
  // Solo aplica a tipo mensaje (CODIGO CHAT) — derivación (AIA) y el resto de
  // tipos se muestran uno por uno, sin agrupar (pedido explícito de negocio).
  static List<Notificacion> _agruparMensajes(List<NotificacionModel> lista) {
    final resultado = <Notificacion>[];
    final chatsProcesados = <int>{};

    for (final n in lista) {
      if (n.tipo != TipoNotificacion.mensaje || n.idChatCab == null) {
        resultado.add(n);
        continue;
      }
      // La lista viene ordenada por FC_USUARIO_C DESC desde el SP, así que la
      // primera notificación de este chat que encontramos es la más reciente.
      if (!chatsProcesados.add(n.idChatCab!)) continue;

      final cantidad = lista
          .where(
            (o) =>
                o.tipo == TipoNotificacion.mensaje &&
                o.idChatCab == n.idChatCab,
          )
          .length;

      resultado.add(
        cantidad > 1
            ? n.copyWith(
                descripcion: _esPropio(n.codUserDestinatario)
                    ? '${n.nombreCliente} te ha enviado $cantidad mensajes.'
                    : '${n.nombreCliente} le ha enviado $cantidad mensajes '
                          'a ${n.codUserDestinatario}.',
              )
            : n,
      );
    }

    return resultado;
  }

  // Agrupación real por T_NOTIFICACION_TIPO.CODIGO — todo lo que no matchea
  // ninguno de los códigos conocidos cae en actividad/negociación genérica
  // (GESTION_DE_CODIGO, GESTION_DE_PAGO, INSCRIPCION_DE_EMPRESAS, y futuros).
  static TipoNotificacion _parseTipo(String codigo) =>
      switch (codigo.toUpperCase()) {
        'AIA' => TipoNotificacion.derivacion,
        'CHAT' => TipoNotificacion.mensaje,
        'RECORDATORIO' => TipoNotificacion.recordatorio,
        'LEAD_POR_CONTACTAR' => TipoNotificacion.leadPorContactar,
        'LEAD_REASIGNADO' => TipoNotificacion.leadReasignado,
        _ => TipoNotificacion.actividad,
      };

  // DATOS para mensaje/derivación (ejemplo real confirmado):
  // "Manuel Antonio Cardenas Valente¦Curso Digital Procurement¦Nuevo mensaje"
  //   0: nombre cliente  1: oportunidad  2: título
  //   3: idChatCab  4: idNumero — PENDIENTE de confirmar con un ejemplo que los traiga
  // nombreCliente se devuelve también sin formatear porque _agruparMensajes
  // lo necesita para reconstruir el texto cuando colapsa varias
  // notificaciones del mismo idChatCab en una sola. oportunidad viaja en la
  // entidad base — la muestra el chip inferior, ya no el texto.
  //
  // codUserDestinatario (2026-08-13) es el CODUSER crudo (sin resolver a
  // nombre — decisión explícita del usuario: el SP ya no hace join a
  // SYSMUSER01, manda el ID_USUARIO tal cual) — se compara contra el CODUSER
  // logueado (_esPropio): si es el propio usuario el texto usa "te" como
  // siempre; si es de otro asesor (vista de moderador viendo el equipo) el
  // texto lo nombra por su CODUSER, ya que no hay nombre resuelto disponible.
  static (String, int?, String, String) _parseDatosChat(
    TipoNotificacion tipo,
    String datosRaw,
    String codUserDestinatario,
  ) {
    final d = ParseUtils.campos(datosRaw, AppConstants.sepCampos);
    final nombreCliente = ParseUtils.str(d, 0);
    final oportunidad = ParseUtils.str(d, 1);
    final idChatCab = int.tryParse(ParseUtils.str(d, 3));

    final esPropio = _esPropio(codUserDestinatario);
    final descripcion = tipo == TipoNotificacion.mensaje
        ? (esPropio
              ? '$nombreCliente te ha enviado un mensaje.'
              : '$nombreCliente le ha enviado un mensaje a $codUserDestinatario.')
        : (esPropio
              ? 'Se te ha derivado $nombreCliente.'
              : 'Se derivó a $nombreCliente hacia $codUserDestinatario.');

    return (descripcion, idChatCab, nombreCliente, oportunidad);
  }

  // DATOS para RECORDATORIOS (SP CSV_NOTIFICACIONES_LST_APP, comentario del
  // SP — el índice de ID_NOTIFICACION al final no se usa acá, ya viene por
  // fuera como campo 0 del CSV general):
  //   0: ID_RECORDATORIO      1: ASESOR_ASIGNADO
  //   2: HORA_RECORDATORIO    3: NOM_ACCION
  //   4: NOM_AVISO            5: MODALIDAD
  //   6: FECHA_HORA_AVISO     7: COMENTARIO
  //   8: NOM_CONTACTO         9: TELEFONO
  static String _parseDatosRecordatorio(String datosRaw) {
    final d = ParseUtils.campos(datosRaw, AppConstants.sepCampos);
    final hora = ParseUtils.str(d, 2);
    final accion = ParseUtils.str(d, 3);
    final modalidad = ParseUtils.str(d, 5);

    return 'Tienes un recordatorio a las $hora: $accion. Modalidad: $modalidad';
  }

  // DATOS para LEADS POR CONTACTAR:
  //   0: ASESOR_ASIGNADO_COD  1-5: DIA_SEMANA/DIA/MES/ANIO/HORA
  //   6: NRO_DOCUMENTO        7: ID_LEAD
  //   8: ID_CONTACTO          9: NOM_CONTACTO
  //   10: DESC_CANAL          11: NOM_EMPRESA
  //   12: TELEFONO            13: NOM_OPORTUNIDAD
  //   14: NOM_ASESOR
  static String _parseDatosLeadPorContactar(String datosRaw) {
    final d = ParseUtils.campos(datosRaw, AppConstants.sepCampos);
    final nombreContacto = ParseUtils.str(d, 9);
    final canal = ParseUtils.str(d, 10);
    final oportunidad = ParseUtils.str(d, 13);

    return 'Tienes una negociación por contactar con $nombreContacto '
        'sobre $oportunidad, vía $canal.';
  }

  // DATOS para LEADS REASIGNADOS — mismo shape que "por contactar" pero con
  // ASESOR_ANTERIOR_COD intercalado, así que los índices desde NOM_CONTACTO
  // en adelante corren distinto:
  //   0: ASESOR_ASIGNADO_COD  1-5: DIA_SEMANA/DIA/MES/ANIO/HORA
  //   6: NRO_DOCUMENTO        7: ID_LEAD
  //   8: ID_CONTACTO          9: ASESOR_ANTERIOR_COD
  //   10: NOM_CONTACTO        11: NOM_EMPRESA
  //   12: TELEFONO            13: NOM_OPORTUNIDAD
  //   14: NOM_ASESOR_NUEVO    15: DESC_CANAL
  //   16: NOM_ASESOR_REASIGNO
  static String _parseDatosLeadReasignado(String datosRaw) {
    final d = ParseUtils.campos(datosRaw, AppConstants.sepCampos);
    final nombreContacto = ParseUtils.str(d, 10);
    final oportunidad = ParseUtils.str(d, 13);
    final canal = ParseUtils.str(d, 15);

    return 'Tienes una negociación reasignada con $nombreContacto '
        'sobre $oportunidad, vía $canal.';
  }
}
