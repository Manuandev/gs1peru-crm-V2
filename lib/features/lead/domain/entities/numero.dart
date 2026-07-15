// lib/features/lead/domain/entities/numero.dart
//
// Canal + estado del número de contacto (T_NUMERO). Un mismo Contacto puede
// tener varios Numero, cada uno con su propio favorito/chat/bloqueado — por
// eso estos flags no viven en [Contacto].

import 'package:app_crm/index_dependencies.dart';

class Numero extends Equatable {
  final int idNumero;
  final String prefijo;
  final String numero;
  final bool isFavorito;

  /// Id de la conversación (T_CONVERSACION_CAB) más reciente de este número —
  /// clave única para abrir ChatDetail. 0 si el número nunca conversó.
  final int idChatCab;

  final bool tieneConversacionAbierta;

  /// Fecha del primer mensaje del CLIENTE en la conversación de [idChatCab]
  /// (CD.FC_USUARIO_C, DIRECCION='CLI') — ancla de la ventana de chat abierto
  /// (TDE), igual que [Chat.fcPrimerMensajeCliente] en `chat/`. Vacío si el
  /// número nunca conversó o el SP todavía no la trae.
  final String fechaPrimerMensajeCliente;

  const Numero({
    required this.idNumero,
    this.prefijo = '',
    this.numero = '',
    this.isFavorito = false,
    this.idChatCab = 0,
    this.tieneConversacionAbierta = false,
    this.fechaPrimerMensajeCliente = '',
  });

  @override
  List<Object?> get props => [
    idNumero,
    prefijo,
    numero,
    isFavorito,
    idChatCab,
    tieneConversacionAbierta,
    fechaPrimerMensajeCliente,
  ];

  Numero copyWith({
    int? idNumero,
    String? prefijo,
    String? numero,
    bool? isFavorito,
    int? idChatCab,
    bool? tieneConversacionAbierta,
    String? fechaPrimerMensajeCliente,
  }) {
    return Numero(
      idNumero: idNumero ?? this.idNumero,
      prefijo: prefijo ?? this.prefijo,
      numero: numero ?? this.numero,
      isFavorito: isFavorito ?? this.isFavorito,
      idChatCab: idChatCab ?? this.idChatCab,
      tieneConversacionAbierta:
          tieneConversacionAbierta ?? this.tieneConversacionAbierta,
      fechaPrimerMensajeCliente:
          fechaPrimerMensajeCliente ?? this.fechaPrimerMensajeCliente,
    );
  }
}
