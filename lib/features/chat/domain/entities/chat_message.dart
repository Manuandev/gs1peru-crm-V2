// lib\features\chat\domain\entities\chat_message.dart

class ChatMessage {
  final String idMensaje; // 00 - ID_MENSAJE
  final String fecha; // 01 - FCH_REGISTRO
  final bool isEnviado; // 02 - FLG_ENTRADA
  final String mensaje; // 03 - MENSAJE
  final String tipo; // 04 - TIPO_MENSAJE
  final String estado; // 05 - ESTADO
  final String nomArchivo; // 06 - ARCHIVO_NOMBRE
  final String extArchivo; // 07 - ARCHIVO_EXT

  const ChatMessage({
    required this.idMensaje,
    required this.fecha,
    required this.isEnviado,
    required this.mensaje,
    required this.tipo,
    required this.estado,
    required this.nomArchivo,
    required this.extArchivo,
  });
}
