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

  // Índices del SP CSV_WHATSAPP_LST_APP (task LS):
  //  0  CT.ID_CONTACTO       23  LE.ID_ESTADO
  //  1  CT.NOMBRES           24  LE.DESCRIPCION    (idEstadoDescripcion)
  //  2  CT.APELLIDO_P        25  EP.ID_ESTADO      (idEstadoPadre)
  //  3  CT.APELLIDO_M        26  EP.DESCRIPCION    (descEstadoPadre)
  //  4  CT.ASESOR_PRINCIPAL  27  CP.ID_CAMPANIA
  //  5  EM.ID_EMPRESA        28  CP.NOMBRE
  //  6  EM.RUC               29  OP.ID_OPORTUNIDAD
  //  7  EM.NOMBRE            30  OP.NOMBRE
  //  8  EM.DIRECCION         31  CN.ID_CANAL
  //  9  NM.ID_NUMERO         32  CN.DESCRIPCION
  // 10  NM.PREFIJO_PAIS      33  IT.ID_INTERES
  // 11  NM.NUMERO            34  IT.DESCRIPCION
  // 12  NM.IB_PRINCIPAL      35  CD.ID_TOKEN_META
  // 13  NM.IB_FAVORITO       36  CD.TIPO
  // 14  NM.IB_BLOQUEADO      37  CD.DIRECCION
  // 15  CC.IB_EXPIRADO       38  CD.CONTENIDO
  // 16  CC.IB_CERRADO        39  CD.ESTADO_ENTREGA
  // 17  LD.ID_LEAD           40  CD.FC_USUARIO_C
  // 18  LD.MODALIDAD         41  CO.ARCHIVO_NOMBRE
  // 19  LD.DC_PRECIO_BASE    42  CO.ARCHIVO_TIPO
  // 20  LD.DC_PRECIO
  // 21  0 (CANTIDAD)         — ignorados en ChatModel
  // 22  0 (DESCUENTO)
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
      // 19-22: precio_base, precio, cantidad, descuento — no aplican en ChatModel
      // Info estado
      idEstado: ParseUtils.str(fields, 23),
      idEstadoDescripcion: ParseUtils.str(fields, 24),
      idEstadoPadre: ParseUtils.str(fields, 25),
      descEstadoPadre: ParseUtils.str(fields, 26),
      // Info campaña
      idCampania: ParseUtils.toInt(fields, 27),
      nombreCampania: ParseUtils.str(fields, 28),
      // Info oportunidad
      idOportunidad: ParseUtils.toInt(fields, 29),
      nombreOportunidad: ParseUtils.str(fields, 30),
      // Info canal
      idCanal: ParseUtils.toInt(fields, 31),
      nombreCanal: ParseUtils.str(fields, 32),
      // Info interes
      idInteres: ParseUtils.toInt(fields, 33),
      nombreInteres: ParseUtils.str(fields, 34),
      // Último mensaje
      idTokenMeta: ParseUtils.str(fields, 35),
      tipo: ParseUtils.str(fields, 36),
      direccionMensaje: ParseUtils.str(fields, 37),
      contenido: ParseUtils.str(fields, 38),
      estadoEntrega: ParseUtils.str(fields, 39),
      fechaHora: ParseUtils.str(fields, 40),
      // Documento si tiene
      archivoNombre: ParseUtils.str(fields, 41),
      archivoTipo: ParseUtils.str(fields, 42),
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
