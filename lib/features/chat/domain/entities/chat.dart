// lib\features\chat\domain\entities\chat.dart

class Chat {
  final String idLead; // 00 - ID_LEAD
  final String idChatCab; // 01 - ID_CHAT_CAB
  final String nombreApe; // 02 - B.NOMBRE + ' ' + B.APELLIDOS
  final String telefono; // 03 - TELEFONO (+51-958914300)
  final String mensaje; // 04 - MENSAJE
  final String fechaHora; // 05 - FCH_REGISTRO
  final bool isFavorito; // 06 - FLG_FAVORITO
  final bool isEnviado; // 07 - FLG_ENTRADA
  final bool isBloqueado; // 08 - LEADS_LISTA_NEGRA (bloqueado)

  const Chat({
    required this.idLead,
    required this.idChatCab,
    required this.nombreApe,
    required this.telefono,
    required this.mensaje,
    required this.fechaHora,
    required this.isFavorito,
    required this.isEnviado,
    required this.isBloqueado,
  });
}
