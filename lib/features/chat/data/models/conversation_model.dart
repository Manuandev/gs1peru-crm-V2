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
    required super.isPrincipal,
    required super.isFavorito,
    required super.isBloqueado,
    // Conversación más reciente de ese número
    required super.isExpirado,
    required super.isCerrado,
    // Lead más reciente de ese número
    required super.idLead,
    required super.modalidad,
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
  });

  // Índices del SP CSV_WHATSAPP_LST_APP (task LS):
  //  0  CT.ID_CONTACTO       20  CP.ID_CAMPANIA
  //  1  CT.NOMBRES           21  CP.NOMBRE
  //  2  CT.APELLIDO_P        22  OP.ID_OPORTUNIDAD
  //  3  CT.APELLIDO_M        23  OP.NOMBRE
  //  4  CT.ASESOR_PRINCIPAL  24  CN.ID_CANAL
  //  5  EM.NOMBRE            25  CN.DESCRIPCION
  //  6  NM.ID_NUMERO         26  IT.ID_INTERES
  //  7  NM.PREFIJO_PAIS      27  IT.DESCRIPCION
  //  8  NM.NUMERO            28  CD.DIRECCION
  //  9  NM.IB_PRINCIPAL      29  CD.FC_USUARIO_C
  // 10  NM.IB_FAVORITO       30  IB_IA.IB_IA_PRIMERO
  // 11  NM.IB_BLOQUEADO      31  PRM_MSG_CLI.FC_USUARIO_C
  // 12  CC.IB_EXPIRADO       32  CD_CLI.TIPO
  // 13  CC.IB_CERRADO        33  CD_CLI.CONTENIDO
  // 14  LD.ID_LEAD           34  CO_CLI.ARCHIVO_NOMBRE
  // 15  LD.MODALIDAD         35  CO_CLI.ARCHIVO_TIPO
  // 16  LE.ID_ESTADO         36  QT_IA.QT_MENSAJES_IA
  // 17  LE.DESCRIPCION       37  FC_IA_LAST.FC_USUARIO_C
  // 18  EP.ID_ESTADO         38  CC.ID_CONVERSACION_CAB
  // 19  EP.DESCRIPCION
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
      isPrincipal: ParseUtils.toBool(fields, 9),
      isFavorito: ParseUtils.toBool(fields, 10),
      isBloqueado: ParseUtils.toBool(fields, 11),
      // Conversación más reciente de ese número
      isExpirado: ParseUtils.toBool(fields, 12),
      isCerrado: ParseUtils.toBool(fields, 13),
      // Lead más reciente de ese número
      idLead: ParseUtils.toInt(fields, 14),
      modalidad: ParseUtils.str(fields, 15),
      // Info estado
      idEstado: ParseUtils.str(fields, 16),
      descEstado: ParseUtils.str(fields, 17),
      idEstadoPadre: ParseUtils.str(fields, 18),
      descEstadoPadre: ParseUtils.str(fields, 19),
      // Info campaña
      idCampania: ParseUtils.toInt(fields, 20),
      nombreCampania: ParseUtils.str(fields, 21),
      // Info oportunidad
      idOportunidad: ParseUtils.toInt(fields, 22),
      nombreOportunidad: ParseUtils.str(fields, 23),
      // Info canal
      idCanal: ParseUtils.toInt(fields, 24),
      nombreCanal: ParseUtils.str(fields, 25),
      // Info interes
      idInteres: ParseUtils.toInt(fields, 26),
      nombreInteres: ParseUtils.str(fields, 27),
      // Último mensaje
      direccionMensaje: ParseUtils.str(fields, 28),
      fechaHora: ParseUtils.str(fields, 29),

      // IBS
      isDerivadoIA: ParseUtils.toBool(fields, 30),
      // Fecha del primer mensaje del cliente
      fcPrimerMensajeCliente: ParseUtils.str(fields, 31),
      // Último mensaje del CLIENTE
      tipoCliente: ParseUtils.str(fields, 32),
      contenidoCliente: ParseUtils.str(fields, 33),
      // Documento del último mensaje del CLIENTE
      archivoNombreCliente: ParseUtils.str(fields, 34),
      archivoTipoCliente: ParseUtils.str(fields, 35),

      // Cantidad de mensajes de la ia
      cantidadMensajesIA: ParseUtils.toInt(fields, 36),
      // Fecha del último mensaje de la IA
      fcUltimoMensajeIA: ParseUtils.str(fields, 37),

      // ID Chat Cab
      idChatCab: ParseUtils.toInt(fields, 38),
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
