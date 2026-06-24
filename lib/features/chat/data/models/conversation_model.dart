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
    required super.idEmpresa,
    required super.ruc,
    required super.nombreEmpresa,
    required super.direccionEmpresa,
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
    required super.idEstadoDescripcion,
    required super.idEstadoPadre,
    super.descEstadoPadre = '',
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
    required super.idTokenMeta,
    required super.tipo,
    required super.direccionMensaje,
    required super.contenido,
    required super.estadoEntrega,
    required super.fechaHora,
    // Documento si tiene
    required super.archivoNombre,
    required super.archivoTipo,
  });

  // Índices del SP (código LS):
  //  0  ID_CONTACTO          19  LE.ID_ESTADO
  //  1  NOMBRES              20  LE.DESCRIPCION   (idEstadoDescripcion)
  //  2  APELLIDO_P           21  EP.ID_ESTADO     (idEstadoPadre)
  //  3  APELLIDO_M           22  EP.DESCRIPCION   (descEstadoPadre)
  //  4  ASESOR_PRINCIPAL     23  CP.ID_CAMPANIA
  //  5  ID_EMPRESA           24  CP.NOMBRE
  //  6  RUC                  25  OP.ID_OPORTUNIDAD
  //  7  EM.NOMBRE            26  OP.NOMBRE
  //  8  EM.DIRECCION         27  CN.ID_CANAL
  //  9  ID_NUMERO            28  CN.DESCRIPCION
  // 10  PREFIJO_PAIS         29  IT.ID_INTERES
  // 11  NUMERO               30  IT.DESCRIPCION
  // 12  IB_PRINCIPAL         31  ID_TOKEN_META
  // 13  IB_FAVORITO          32  TIPO
  // 14  IB_BLOQUEADO         33  DIRECCION
  // 15  IB_EXPIRADO          34  CONTENIDO
  // 16  IB_CERRADO           35  ESTADO_ENTREGA
  // 17  ID_LEAD              36  FC_USUARIO_C
  // 18  MODALIDAD            37  ARCHIVO_NOMBRE
  //                          38  ARCHIVO_TIPO
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
      idEmpresa: ParseUtils.toInt(fields, 5),
      ruc: ParseUtils.str(fields, 6),
      nombreEmpresa: ParseUtils.str(fields, 7),
      direccionEmpresa: ParseUtils.str(fields, 8),
      // Numero
      idNumero: ParseUtils.toInt(fields, 9),
      prefijoPais: ParseUtils.str(fields, 10),
      numero: ParseUtils.str(fields, 11),
      isPrincipal: ParseUtils.toBool(fields, 12),
      isFavorito: ParseUtils.toBool(fields, 13),
      isBloqueado: ParseUtils.toBool(fields, 14),
      // Conversación más reciente de ese número
      isExpirado: ParseUtils.toBool(fields, 15),
      isCerrado: ParseUtils.toBool(fields, 16),
      // Lead más reciente de ese número
      idLead: ParseUtils.toInt(fields, 17),
      modalidad: ParseUtils.str(fields, 18),
      // Info estado
      idEstado: ParseUtils.str(fields, 19),
      idEstadoDescripcion: ParseUtils.str(fields, 20), // LE.DESCRIPCION
      idEstadoPadre: ParseUtils.str(fields, 21), // EP.ID_ESTADO
      descEstadoPadre: ParseUtils.str(fields, 22), // EP.DESCRIPCION (nuevo)
      // Info campaña
      idCampania: ParseUtils.toInt(fields, 23),
      nombreCampania: ParseUtils.str(fields, 24),
      // Info oportunidad
      idOportunidad: ParseUtils.toInt(fields, 25),
      nombreOportunidad: ParseUtils.str(fields, 26),
      // Info canal
      idCanal: ParseUtils.toInt(fields, 27),
      nombreCanal: ParseUtils.str(fields, 28),
      // Info interes
      idInteres: ParseUtils.toInt(fields, 29),
      nombreInteres: ParseUtils.str(fields, 30),
      // Último mensaje
      idTokenMeta: ParseUtils.str(fields, 31),
      tipo: ParseUtils.str(fields, 32),
      direccionMensaje: ParseUtils.str(fields, 33),
      contenido: ParseUtils.str(fields, 34),
      estadoEntrega: ParseUtils.str(fields, 35),
      fechaHora: ParseUtils.str(fields, 36),
      // Documento si tiene
      archivoNombre: ParseUtils.str(fields, 37),
      archivoTipo: ParseUtils.str(fields, 38),
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
