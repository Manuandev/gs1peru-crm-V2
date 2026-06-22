// lib/features/chat/data/models/chat_model.dart

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
    required super.idEstadoPadre,
    required super.idEstadoDescripcion,
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

  factory ChatModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return ChatModel(
      // Contacto
      idContacto: ParseUtils.toInt(fields, 0),
      nombres: ParseUtils.str(fields, 1),
      apellidoPaterno: ParseUtils.str(fields, 2),
      apellidoMaterno: ParseUtils.str(fields, 3),
      asesor: ParseUtils.str(fields, 4),
      //Empresa
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
      idEstadoPadre: ParseUtils.str(fields, 20),
      idEstadoDescripcion: ParseUtils.str(fields, 21),
      // Info campaña
      idCampania: ParseUtils.toInt(fields, 22),
      nombreCampania: ParseUtils.str(fields, 23),
      // Info oportunidad
      idOportunidad: ParseUtils.toInt(fields, 24),
      nombreOportunidad: ParseUtils.str(fields, 25),
      // Info canal
      idCanal: ParseUtils.toInt(fields, 26),
      nombreCanal: ParseUtils.str(fields, 27),
      // Info interes
      idInteres: ParseUtils.toInt(fields, 28),
      nombreInteres: ParseUtils.str(fields, 29),
      // Último mensaje
      idTokenMeta: ParseUtils.str(fields, 30),
      tipo: ParseUtils.str(fields, 31),
      direccionMensaje: ParseUtils.str(fields, 32),
      contenido: ParseUtils.str(fields, 33),
      estadoEntrega: ParseUtils.str(fields, 34),
      fechaHora: ParseUtils.str(fields, 35),
      // Documento si tiene
      archivoNombre: ParseUtils.str(fields, 36),
      archivoTipo: ParseUtils.str(fields, 37),
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
