// lib/features/lead/domain/entities/numero_contacto.dart
//
// Celular editable de un contacto (T_NUMERO / T_CONTACTO_NUMERO) — vive
// aparte de [Numero] (el número "ancla" de una negociación, con datos de
// conversación de WhatsApp) porque acá se necesita el estado de edición
// completo: principal/favorito/activo, sin idChatCab ni fechas.

import 'package:app_crm/index_dependencies.dart';

class NumeroContacto extends Equatable {
  final int idNumero;
  final String prefijo; // código de país, ej. '+51'
  final String numero;
  final bool esPrincipal;
  final bool esFavorito;
  final bool activo;

  const NumeroContacto({
    this.idNumero = 0,
    this.prefijo = '',
    this.numero = '',
    this.esPrincipal = false,
    this.esFavorito = false,
    this.activo = true,
  });

  NumeroContacto copyWith({
    int? idNumero,
    String? prefijo,
    String? numero,
    bool? esPrincipal,
    bool? esFavorito,
    bool? activo,
  }) {
    return NumeroContacto(
      idNumero: idNumero ?? this.idNumero,
      prefijo: prefijo ?? this.prefijo,
      numero: numero ?? this.numero,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      esFavorito: esFavorito ?? this.esFavorito,
      activo: activo ?? this.activo,
    );
  }

  @override
  List<Object?> get props => [
    idNumero,
    prefijo,
    numero,
    esPrincipal,
    esFavorito,
    activo,
  ];
}
