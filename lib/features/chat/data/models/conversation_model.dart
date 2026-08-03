// lib/features/chat/data/models/conversation_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    // Contacto
    required super.idContacto,
    required super.nombres,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.asesor,
    //Empresa
    required super.nombreEmpresa,
    // Numero
    required super.idNumero,
    required super.prefijoPais,
    required super.numero,
    required super.isFavorito,
    required super.isBloqueado,
    // Lead más reciente de ese número
    required super.idLead,
    // Info estado
    required super.idEstado,
    required super.descEstado,
    required super.idEstadoPadre,
    required super.descEstadoPadre,
    // Info campaña
    required super.idCampania,
    required super.nombreCampania,
    // Info oportunidad
    required super.idOportunidad,
    required super.nombreOportunidad,
    // Info canal
    required super.idCanal,
    required super.nombreCanal,
    // Info interes
    required super.idInteres,
    required super.nombreInteres,
    // Último mensaje
    required super.direccionMensaje,
    required super.fechaHora,

    // IBS
    required super.isDerivadoIA,
    // Fecha del primer mensaje del cliente
    required super.fcPrimerMensajeCliente,
    // Último mensaje del CLIENTE
    required super.tipoCliente,
    required super.contenidoCliente,
    // Documento del último mensaje del CLIENTE
    required super.archivoNombreCliente,
    required super.archivoTipoCliente,

    // Cantidad de mensajes de la ia
    required super.cantidadMensajesIA,
    super.fcUltimoMensajeIA,

    // ID Chat Cab
    required super.idChatCab,

    super.cargo,
    super.correo,

    // Fecha del último mensaje del cliente
    required super.fcUltimoMensajeCliente,
  });

  // Índices del SP de lista de chats (tasks 'LS' y 'LU' — misma forma, 'LU'
  // filtrada a 1 fila por ID_CONVERSACION_CAB). modalidad/isExpirado/
  // isCerrado ya no vienen acá — pendientes del SP de detalle de chat.
  //  0  CT.ID_CONTACTO       18  OP.ID_OPORTUNIDAD
  //  1  CT.NOMBRES           19  OP.NOMBRE
  //  2  CT.APELLIDO_P        20  CN.ID_CANAL
  //  3  CT.APELLIDO_M        21  CN.NOMBRE
  //  4  CT.ASESOR_PRINCIPAL  22  IT.ID_INTERES
  //  5  EM.NOMBRE            23  IT.DESCRIPCION
  //  6  NM.ID_NUMERO         24  CD.DIRECCION
  //  7  NM.PREFIJO_PAIS      25  CD.FC_USUARIO_C
  //  8  NM.NUMERO            26  IB_IA.IB_IA_PRIMERO
  //  9  NM.IB_FAVORITO       27  PRM_MSG_CLI.FC_USUARIO_C
  // 10  NM.IB_BLOQUEADO      28  CD_CLI.TIPO
  // 11  LD.ID_LEAD           29  CD_CLI.CONTENIDO
  // 12  LE.ID_ESTADO         30  CO_CLI.ARCHIVO_NOMBRE
  // 13  LE.DESCRIPCION       31  CO_CLI.ARCHIVO_TIPO
  // 14  EP.ID_ESTADO         32  QT_IA.QT_MENSAJES_IA
  // 15  EP.DESCRIPCION       33  FC_IA_LAST.FC_USUARIO_C
  // 16  CP.ID_CAMPANIA       34  CC.ID_CONVERSACION_CAB
  // 17  CP.NOMBRE            35  CE.NOM_CARGO (T_EMPRESA_CONTACTO, texto
  //                              libre — 2026-08-03, verificado; el cargo
  //                              vive en la empresa vinculada, no en
  //                              T_CONTACTO.ID_CARGO, columna vieja sin uso)
  //                          36  CO.CORREO
  factory ChatModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return ChatModel(
      // Contacto
      idContacto: ParseUtils.toInt(fields, 0),
      nombres: ParseUtils.str(fields, 1),
      apellidoPaterno: ParseUtils.str(fields, 2),
      apellidoMaterno: ParseUtils.str(fields, 3),
      asesor: ParseUtils.str(fields, 4),
      // Empresa
      nombreEmpresa: ParseUtils.str(fields, 5),
      // Numero
      idNumero: ParseUtils.toInt(fields, 6),
      prefijoPais: ParseUtils.str(fields, 7),
      numero: ParseUtils.str(fields, 8),
      isFavorito: ParseUtils.toBool(fields, 9),
      isBloqueado: ParseUtils.toBool(fields, 10),
      // Lead más reciente de ese número
      idLead: ParseUtils.toInt(fields, 11),
      // Info estado
      idEstado: ParseUtils.str(fields, 12),
      descEstado: ParseUtils.str(fields, 13),
      idEstadoPadre: ParseUtils.str(fields, 14),
      descEstadoPadre: ParseUtils.str(fields, 15),
      // Info campaña
      idCampania: ParseUtils.toInt(fields, 16),
      nombreCampania: ParseUtils.str(fields, 17),
      // Info oportunidad
      idOportunidad: ParseUtils.toInt(fields, 18),
      nombreOportunidad: ParseUtils.str(fields, 19),
      // Info canal
      idCanal: ParseUtils.toInt(fields, 20),
      nombreCanal: ParseUtils.str(fields, 21),
      // Info interes
      idInteres: ParseUtils.toInt(fields, 22),
      nombreInteres: ParseUtils.str(fields, 23),
      // Último mensaje
      direccionMensaje: ParseUtils.str(fields, 24),
      fechaHora: ParseUtils.str(fields, 25),

      // IBS
      isDerivadoIA: ParseUtils.toBool(fields, 26),
      // Fecha del primer mensaje del cliente
      fcPrimerMensajeCliente: ParseUtils.str(fields, 27),
      // Último mensaje del CLIENTE
      tipoCliente: ParseUtils.str(fields, 28),
      contenidoCliente: ParseUtils.str(fields, 29),
      // Documento del último mensaje del CLIENTE
      archivoNombreCliente: ParseUtils.str(fields, 30),
      archivoTipoCliente: ParseUtils.str(fields, 31),

      // Cantidad de mensajes de la ia
      cantidadMensajesIA: ParseUtils.toInt(fields, 32),
      // Fecha del último mensaje de la IA
      fcUltimoMensajeIA: ParseUtils.str(fields, 33),

      // ID Chat Cab
      idChatCab: ParseUtils.toInt(fields, 34),

      cargo: ParseUtils.strNullable(fields, 35),
      correo: ParseUtils.strNullable(fields, 36),

      fcUltimoMensajeCliente: ParseUtils.str(fields, 37),
    );
  }

  static List<ChatModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ChatModel.fromRawString(r))
        .toList();
  }
}
