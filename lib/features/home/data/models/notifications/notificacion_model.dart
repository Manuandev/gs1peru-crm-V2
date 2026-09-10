// lib/features/home/data/models/notifications/notificacion_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificacionModel extends Notificacion {
  // Solo se llenan en mensaje/derivación — nombreCliente/codUserDestinatario
  // se usan para armar el texto. oportunidad sí viaja en la entidad base
  // (Notificacion) porque la UI la necesita para el chip.
  final String nombreCliente;
  // CODUSER crudo del destinatario (NT.ID_USUARIO tal cual, sin join a
  // nombre) — vacío si el campo no vino en el CSV.
  final String codUserDestinatario;
  // Cuántas notificaciones colapsó el SP en esta fila. Solo > 1 en mensajes
  // (CODIGO 'CHAT', agrupados por ID_REFERENCIA = ID_CONVERSACION_CAB); 1 en
  // todo lo demás. Antes esto se calculaba en el cliente (_agruparMensajes),
  // pero con paginación dos mensajes del mismo chat pueden caer en páginas
  // distintas — la agrupación se movió al SP (2026-09-10).
  final int cantidad;

  const NotificacionModel({
    required super.id,
    required super.idLead,
    required super.tipo,
    required super.titulo,
    required super.descripcion,
    required super.fechaHora,
    required super.leido,
    super.idChatCab,
    super.idContacto,
    super.oportunidad,
    this.nombreCliente = '',
    this.codUserDestinatario = '',
    this.cantidad = 1,
  });

  // Campos del SP CSV_NOTIFICACIONES_LST_APP (separados por ¦):
  // 0: ID_NOTIFICACION
  // 1: ID_REFERENCIA        — id del lead, o ID_CONVERSACION_CAB si es CHAT
  // 2: ID_TIPO_NOTIFICACION — no se usa directo, el tipo sale de CODIGO
  // 3: TITULO
  // 4: DATOS                — armado desde el INSERT, usa ¦ como separador
  //                           interno también, así que puede traer más ¦ de
  //                           los que le tocan (ver reconstrucción abajo)
  // ...: IB_LEIDO, NOMBRE, CODIGO, FC_USUARIO_C, ID_USUARIO, CANTIDAD —
  //      últimos 6 campos fijos. ⚠️ Eran 5 hasta 2026-09-10; CANTIDAD se
  //      agregó al final con la paginación, por eso los offsets son n-6..n-1.
  //      Si se agrega otro campo fijo hay que correr TODOS estos índices.
  factory NotificacionModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    final n = c.length;

    // DATOS (campo 4) usa el mismo separador ¦ como interno, así que no se
    // puede tomar como un campo más — se reconstruye con todo lo que sobra
    // entre los 4 campos fijos del inicio (0-3) y los 6 fijos del final.
    final datosRaw = n > 10
        ? c.sublist(4, n - 6).join(AppConstants.sepCampos)
        : ParseUtils.str(c, 4);

    final tipo = _parseTipo(ParseUtils.str(c, n - 4));
    final codUserDestinatario = ParseUtils.str(c, n - 2);
    final cantidad = ParseUtils.toInt(c, n - 1);

    var descripcion = datosRaw;
    int? idChatCab;
    int? idContacto;
    var nombreCliente = '';
    var oportunidad = '';

    if (tipo == TipoNotificacion.mensaje ||
        tipo == TipoNotificacion.derivacion) {
      final (desc, chatCab, nombre, oport) = _parseDatosChat(
        tipo,
        datosRaw,
        codUserDestinatario,
        cantidad,
      );
      descripcion = desc;
      idChatCab = chatCab;
      nombreCliente = nombre;
      oportunidad = oport;
    } else if (tipo == TipoNotificacion.recordatorio) {
      final (desc, contacto) = _parseDatosRecordatorio(
        datosRaw,
        codUserDestinatario,
      );
      descripcion = desc;
      idContacto = contacto;
    } else if (tipo == TipoNotificacion.leadPorContactar) {
      final (desc, contacto, oport) = _parseDatosLeadPorContactar(
        datosRaw,
        codUserDestinatario,
      );
      descripcion = desc;
      idContacto = contacto;
      oportunidad = oport;
    } else if (tipo == TipoNotificacion.leadReasignado) {
      final (desc, contacto, oport) = _parseDatosLeadReasignado(
        datosRaw,
        codUserDestinatario,
      );
      descripcion = desc;
      idContacto = contacto;
      oportunidad = oport;
    } else if (datosRaw.contains(AppConstants.sepCampos)) {
      // Actividad genérica (GESTION_DE_CODIGO, GESTION_DE_PAGO,
      // INSCRIPCION_DE_EMPRESAS y códigos futuros): no hay shape de DATOS
      // definido para estos tipos, así que no se puede redactar el detalle.
      // Se cae a un texto neutro en vez de pintar el CSV crudo, que dejaba
      // la cadena del SP a la vista. El sujeto sí se resuelve igual que en
      // el resto: codUserDestinatario es un campo fijo de la cola, no vive
      // dentro de DATOS, así que está disponible para cualquier tipo.
      // Un DATOS de un solo campo se respeta tal cual: ahí es texto plano.
      descripcion = _esPropio(codUserDestinatario)
          ? 'Tienes una nueva actividad pendiente.'
          : '$codUserDestinatario tiene una nueva actividad pendiente.';
    }

    return NotificacionModel(
      id: ParseUtils.toInt(c, 0),
      idLead: ParseUtils.toInt(c, 1),
      tipo: tipo,
      titulo: ParseUtils.str(c, 3),
      descripcion: descripcion,
      fechaHora: ParseUtils.str(c, n - 3),
      leido: ParseUtils.toBool(c, n - 6),
      idChatCab: idChatCab,
      idContacto: idContacto,
      oportunidad: oportunidad,
      nombreCliente: nombreCliente,
      codUserDestinatario: codUserDestinatario,
      cantidad: cantidad < 1 ? 1 : cantidad,
    );
  }

  // true si el destinatario de la notificación es el usuario logueado —
  // en ese caso el texto usa "te" en vez de nombrar el CODUSER destinatario.
  static bool _esPropio(String codUserDestinatario) =>
      codUserDestinatario.trim().toUpperCase() ==
      SessionService().codUser.trim().toUpperCase();

  // Texto de las tarjetas de negociación (leadPorContactar / leadReasignado).
  //
  // El sujeto se resuelve con el MISMO criterio que mensajes/derivaciones
  // (_esPropio sobre el CODUSER crudo): "Tienes una negociación..." cuando la
  // notificación es del usuario logueado, "GCASTRO tiene una negociación..."
  // cuando un moderador está viendo la de otro asesor. Se nombra por CODUSER
  // y no por NOM_ASESOR (que también viaja en DATOS) para no romper la
  // consistencia con el texto de los mensajes — decisión del usuario.
  //
  // La oportunidad NO entra acá: va en el chip inferior de la tarjeta
  // (Notificacion.etiquetaPrincipal).
  //
  // "vía <canal>" es condicional porque DESC_CANAL llega vacío en buena parte
  // de las filas reales — concatenado a ciegas dejaba el texto en "vía .".
  static String _textoNegociacion({
    required String asesor,
    required String calificador,
    required String nombreContacto,
    required String canal,
  }) {
    final sujeto = _esPropio(asesor) ? 'Tienes' : '$asesor tiene';
    final via = canal.isEmpty ? '' : ', vía $canal';
    return '$sujeto una negociación $calificador con $nombreContacto$via.';
  }

  /// Filas de una página. Ya vienen agrupadas desde el SP — el cliente no
  /// vuelve a colapsar nada (ver [cantidad]).
  static List<Notificacion> parseList(String rawResponse) => rawResponse
      .split(AppConstants.sepRegistros)
      .where((r) => r.trim().isNotEmpty)
      .map((r) => NotificacionModel.fromRawString(r))
      .toList();

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
  //   3: idChatCab (= ID_CONVERSACION_CAB)  4: idNumero
  //
  // codUserDestinatario es el CODUSER crudo (sin resolver a nombre — decisión
  // explícita del usuario: el SP manda ID_USUARIO tal cual) — se compara
  // contra el CODUSER logueado (_esPropio): si es el propio usuario el texto
  // usa "te"; si es de otro asesor (moderador viendo el equipo) lo nombra por
  // su CODUSER, único dato disponible.
  //
  // [cantidad] viene del SP: > 1 cuando colapsó varios mensajes del mismo
  // chat. Solo cambia el texto en tipo mensaje — una derivación nunca agrupa.
  static (String, int?, String, String) _parseDatosChat(
    TipoNotificacion tipo,
    String datosRaw,
    String codUserDestinatario,
    int cantidad,
  ) {
    final d = ParseUtils.campos(datosRaw, AppConstants.sepCampos);
    final nombreCliente = ParseUtils.str(d, 0);
    final oportunidad = ParseUtils.str(d, 1);
    final idChatCab = int.tryParse(ParseUtils.str(d, 3));

    final esPropio = _esPropio(codUserDestinatario);
    final String descripcion;

    if (tipo == TipoNotificacion.mensaje) {
      final cuantos = cantidad > 1 ? '$cantidad mensajes' : 'un mensaje';
      descripcion = esPropio
          ? '$nombreCliente te ha enviado $cuantos.'
          : '$nombreCliente le ha enviado $cuantos a $codUserDestinatario.';
    } else {
      descripcion = esPropio
          ? 'Se te ha derivado $nombreCliente.'
          : 'Se derivó a $nombreCliente hacia $codUserDestinatario.';
    }

    return (descripcion, idChatCab, nombreCliente, oportunidad);
  }

  // DATOS para RECORDATORIOS:
  //   0: ID_RECORDATORIO      1: ASESOR_ASIGNADO
  //   2: HORA_RECORDATORIO    3: NOM_ACCION
  //   4: NOM_AVISO            5: MODALIDAD
  //   6: FECHA_HORA_AVISO     7: COMENTARIO
  //   8: NOM_CONTACTO         9: TELEFONO
  //   10: ID_CONTACTO
  // idContacto (índice 10) se devuelve además del texto — lo usa "Ver
  // seguimiento" (_onAccion en notifications_portrait.dart) para navegar a
  // detalle de contacto, mismo mecanismo que leadPorContactar/leadReasignado.
  // Este tipo NO trae oportunidad en su DATOS, por eso su chip cae al label
  // fijo "Recordatorio" (ver Notificacion.etiquetaPrincipal).
  static (String, int?) _parseDatosRecordatorio(
    String datosRaw,
    String codUserDestinatario,
  ) {
    final d = ParseUtils.campos(datosRaw, AppConstants.sepCampos);
    final hora = ParseUtils.str(d, 2);
    final accion = ParseUtils.str(d, 3);
    final modalidad = ParseUtils.str(d, 5);
    final idContacto = int.tryParse(ParseUtils.str(d, 10));

    // Mismo sujeto que el resto de tipos: "Tienes..." si la notificación es
    // del usuario logueado, "<CODUSER> tiene..." si es de otro asesor. El
    // fallback sale del propio DATOS (campo 1 = ASESOR_ASIGNADO).
    final asesor = codUserDestinatario.isEmpty
        ? ParseUtils.str(d, 1)
        : codUserDestinatario;
    final sujeto = _esPropio(asesor) ? 'Tienes' : '$asesor tiene';
    // Modalidad condicional — sin la guarda el texto terminaba en
    // "Modalidad: " colgando cuando el campo venía vacío.
    final conModalidad = modalidad.isEmpty ? '' : ' Modalidad: $modalidad.';

    final descripcion =
        '$sujeto un recordatorio a las $hora: $accion.$conModalidad';
    return (descripcion, idContacto);
  }

  // DATOS para LEADS POR CONTACTAR:
  //   0: ASESOR_ASIGNADO_COD  1-5: DIA_SEMANA/DIA/MES/ANIO/HORA
  //   6: NRO_DOCUMENTO        7: ID_LEAD
  //   8: ID_CONTACTO          9: NOM_CONTACTO
  //   10: DESC_CANAL          11: NOM_EMPRESA
  //   12: TELEFONO            13: NOM_OPORTUNIDAD
  //   14: NOM_ASESOR
  static (String, int?, String) _parseDatosLeadPorContactar(
    String datosRaw,
    String codUserDestinatario,
  ) {
    final d = ParseUtils.campos(datosRaw, AppConstants.sepCampos);
    final idContacto = int.tryParse(ParseUtils.str(d, 8));
    final nombreContacto = ParseUtils.str(d, 9);
    final canal = ParseUtils.str(d, 10);
    final oportunidad = ParseUtils.str(d, 13);

    final descripcion = _textoNegociacion(
      asesor: codUserDestinatario.isEmpty
          ? ParseUtils.str(d, 0)
          : codUserDestinatario,
      calificador: 'por contactar',
      nombreContacto: nombreContacto,
      canal: canal,
    );
    // oportunidad se devuelve pero YA NO se nombra en el texto: alimenta solo
    // el chip inferior (Notificacion.etiquetaPrincipal), que desde 2026-09-10
    // la muestra en todos los tipos que la traigan. Antes salía en ambos
    // lados y se leía duplicada en la misma tarjeta.
    return (descripcion, idContacto, oportunidad);
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
  static (String, int?, String) _parseDatosLeadReasignado(
    String datosRaw,
    String codUserDestinatario,
  ) {
    final d = ParseUtils.campos(datosRaw, AppConstants.sepCampos);
    final idContacto = int.tryParse(ParseUtils.str(d, 8));
    final nombreContacto = ParseUtils.str(d, 10);
    final oportunidad = ParseUtils.str(d, 13);
    final canal = ParseUtils.str(d, 15);

    final descripcion = _textoNegociacion(
      asesor: codUserDestinatario.isEmpty
          ? ParseUtils.str(d, 0)
          : codUserDestinatario,
      calificador: 'reasignada',
      nombreContacto: nombreContacto,
      canal: canal,
    );
    // oportunidad va SOLO al chip inferior — ver nota en
    // _parseDatosLeadPorContactar.
    return (descripcion, idContacto, oportunidad);
  }
}

/// Parser de la respuesta paginada del task 'LS' (2026-09-10). Formato:
///
///   primera página : "todas¦actividades¦derivaciones¦mensajes¦noLeidas" ¯ filas
///   siguientes     : filas
///   sin datos      : ""  (ApiEmpty)
///
/// El cursor de la página siguiente sale de la ÚLTIMA fila: su `fechaHora`
/// (FC_USUARIO_C en formato 126, campo 08) + su `id` (ID_NOTIFICACION, campo 00).
class NotificacionesPaginaModel {
  const NotificacionesPaginaModel._();

  static NotificacionesPagina parse(String raw) {
    if (raw.trim().isEmpty) return NotificacionesPagina.vacia;

    // Bloques ¯: si hay 2+, el primero son los contadores (solo 1ra página).
    final bloques = raw.split(AppConstants.sepListas);
    NotificacionesConteos? conteos;
    String filasRaw;
    if (bloques.length >= 2) {
      conteos = _parseConteos(bloques.first);
      filasRaw = bloques.sublist(1).join(AppConstants.sepListas);
    } else {
      filasRaw = raw;
    }

    final items = NotificacionModel.parseList(filasRaw);
    final ultima = items.isEmpty ? null : items.last;

    return NotificacionesPagina(
      items: items,
      conteos: conteos,
      cursorFecha: ultima?.fechaHora,
      cursorId: ultima?.id,
    );
  }

  static NotificacionesConteos _parseConteos(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return NotificacionesConteos(
      todas: ParseUtils.toInt(c, 0),
      actividades: ParseUtils.toInt(c, 1),
      derivaciones: ParseUtils.toInt(c, 2),
      mensajes: ParseUtils.toInt(c, 3),
      noLeidas: ParseUtils.toInt(c, 4),
    );
  }
}
