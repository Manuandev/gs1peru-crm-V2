// lib/features/chat/domain/entities/conversation.dart

import 'package:app_crm/index_dependencies.dart';

class Chat extends Equatable {
  // Contacto
  final int idContacto;
  final String nombres;
  final String? apellidoPaterno;
  final String? apellidoMaterno;
  final String? asesor;
  //Empresa
  final String nombreEmpresa;
  // Numero
  final int idNumero;
  final String prefijoPais;
  final String numero;
  final bool isPrincipal;
  final bool isFavorito;
  final bool isBloqueado;
  // Conversación más reciente de ese número
  final bool isExpirado;
  final bool isCerrado;
  // Lead más reciente de ese número
  final int idLead;
  final String modalidad;
  // Info estado
  final String idEstado;
  final String descEstado;
  final String idEstadoPadre;
  final String descEstadoPadre;
  // Info campaña
  final int idCampania;
  final String nombreCampania;
  // Info oportunidad
  final int idOportunidad;
  final String nombreOportunidad;
  // Info canal
  final int idCanal;
  final String nombreCanal;
  // Info interes
  final int idInteres;
  final String nombreInteres;
  // Último mensaje en General
  final String
  direccionMensaje; // AIA - ASISTENTE IA  / ASE - ASESOR / CLI - CLIENTE
  final String fechaHora;

  // IBS
  final bool isDerivadoIA;
  // Fecha del primer mensaje del cliente
  final String fcPrimerMensajeCliente;
  // Último mensaje del CLIENTE
  final String tipoCliente;
  final String contenidoCliente;
  // Documento del último mensaje del CLIENTE
  final String archivoNombreCliente;
  final String archivoTipoCliente;

  // Cantidad de mensajes de la ia
  final int cantidadMensajesIA;

  // Fecha del último mensaje enviado por la IA (para calcular "Transferido hace X")
  final String fcUltimoMensajeIA;

  final int idChatCab;

  /// Retorna el id del estado a mostrar en UI: padre si existe, directo si no.
  String get idEstadoEfectivo =>
      idEstadoPadre.isNotEmpty ? idEstadoPadre : idEstado;

  /// Retorna la descripción del estado efectivo.
  String get descEstadoEfectiva =>
      idEstadoPadre.isNotEmpty ? descEstadoPadre : descEstado;

  /// Nombre completo del contacto. Si no tiene nombre/apellidos registrados,
  /// muestra el número de teléfono como identificador.
  String get nombreCompleto {
    final partes = [
      nombres,
      apellidoPaterno ?? '',
      apellidoMaterno ?? '',
    ].where((parte) => parte.trim().isNotEmpty).join(' ');
    return partes.isNotEmpty ? partes : '$prefijoPais $numero';
  }

  const Chat({
    // Contacto
    required this.idContacto,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.asesor,
    //Empresa
    required this.nombreEmpresa,
    // Numero
    required this.idNumero,
    required this.prefijoPais,
    required this.numero,
    required this.isPrincipal,
    required this.isFavorito,
    required this.isBloqueado,
    // Conversación más reciente de ese número
    required this.isExpirado,
    required this.isCerrado,
    // Lead más reciente de ese número
    required this.idLead,
    required this.modalidad,
    // Info estado
    required this.idEstado,
    required this.descEstado,
    required this.idEstadoPadre,
    required this.descEstadoPadre,
    // Info campaña
    required this.idCampania,
    required this.nombreCampania,
    // Info oportunidad
    required this.idOportunidad,
    required this.nombreOportunidad,
    // Info canal
    required this.idCanal,
    required this.nombreCanal,
    // Info interes
    required this.idInteres,
    required this.nombreInteres,
    // Último mensaje
    required this.direccionMensaje,
    required this.fechaHora,

    // IBS
    required this.isDerivadoIA,
    // Fecha del primer mensaje del cliente
    required this.fcPrimerMensajeCliente,
    // Último mensaje del CLIENTE
    required this.tipoCliente,
    required this.contenidoCliente,
    // Documento del último mensaje del CLIENTE
    required this.archivoNombreCliente,
    required this.archivoTipoCliente,

    // Cantidad de mensajes de la ia
    required this.cantidadMensajesIA,
    // Fecha del último mensaje de la IA
    this.fcUltimoMensajeIA = '',

    required this.idChatCab,
  });

  @override
  List<Object?> get props => [
    // Contacto
    idContacto,
    nombres,
    apellidoPaterno,
    apellidoMaterno,
    asesor,
    //Empresa
    nombreEmpresa,
    // Numero
    idNumero,
    prefijoPais,
    numero,
    isPrincipal,
    isFavorito,
    isBloqueado,
    // Conversación más reciente de ese número
    isExpirado,
    isCerrado,
    // Lead más reciente de ese número
    idLead,
    modalidad,
    // Info estado
    idEstado,
    descEstado,
    idEstadoPadre,
    descEstadoPadre,
    // Info campaña
    idCampania,
    nombreCampania,
    // Info oportunidad
    idOportunidad,
    nombreOportunidad,
    // Info canal
    idCanal,
    nombreCanal,
    // Info interes
    idInteres,
    nombreInteres,
    // Último mensaje
    direccionMensaje,
    fechaHora,

    // Cantidad de mensajes de la ia
    cantidadMensajesIA,
    fcUltimoMensajeIA,

    idChatCab,
  ];

  Chat copyWith({
    int? idContacto,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? asesor,
    String? nombreEmpresa,
    int? idNumero,
    String? prefijoPais,
    String? numero,
    bool? isPrincipal,
    bool? isFavorito,
    bool? isBloqueado,
    // Conversación más reciente de ese número
    bool? isExpirado,
    bool? isCerrado,
    // Lead más reciente de ese número
    int? idLead,
    String? modalidad,
    // Info estado
    String? idEstado,
    String? descEstado,
    String? idEstadoPadre,
    String? descEstadoPadre,
    // Info campaña
    int? idCampania,
    String? nombreCampania,
    // Info oportunidad
    int? idOportunidad,
    String? nombreOportunidad,
    // Info canal
    int? idCanal,
    String? nombreCanal,
    // Info interes
    int? idInteres,
    String? nombreInteres,

    // Último mensaje
    String? direccionMensaje,
    String? fechaHora,

    // IBS
    bool? isDerivadoIA,
    // Fecha del primer mensaje del cliente
    String? fcPrimerMensajeCliente,
    // Último mensaje del CLIENTE
    String? tipoCliente,
    String? contenidoCliente,
    // Documento del último mensaje del CLIENTE
    String? archivoNombreCliente,
    String? archivoTipoCliente,

    // Cantidad de mensajes de la ia
    int? cantidadMensajesIA,
    String? fcUltimoMensajeIA,

    int? idChatCab,
  }) {
    return Chat(
      // Contacto
      idContacto: idContacto ?? this.idContacto,
      nombres: nombres ?? this.nombres,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      asesor: asesor ?? this.asesor,
      //Empresa
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      // Numero
      idNumero: idNumero ?? this.idNumero,
      prefijoPais: prefijoPais ?? this.prefijoPais,
      numero: numero ?? this.numero,
      isPrincipal: isPrincipal ?? this.isPrincipal,
      isFavorito: isFavorito ?? this.isFavorito,
      isBloqueado: isBloqueado ?? this.isBloqueado,
      //Conversación más reciente de ese número
      isExpirado: isExpirado ?? this.isExpirado,
      isCerrado: isCerrado ?? this.isCerrado,
      // Lead más reciente de ese número
      idLead: idLead ?? this.idLead,
      modalidad: modalidad ?? this.modalidad,
      //Info Estado
      idEstado: idEstado ?? this.idEstado,
      descEstado: descEstado ?? this.descEstado,
      idEstadoPadre: idEstadoPadre ?? this.idEstadoPadre,
      descEstadoPadre: descEstadoPadre ?? this.descEstadoPadre,
      // Info Campaña
      idCampania: idCampania ?? this.idCampania,
      nombreCampania: nombreCampania ?? this.nombreCampania,
      // Info oportunidad
      idOportunidad: idOportunidad ?? this.idOportunidad,
      nombreOportunidad: nombreOportunidad ?? this.nombreOportunidad,
      // Info canal
      idCanal: idCanal ?? this.idCanal,
      nombreCanal: nombreCanal ?? this.nombreCanal,
      // Info interes
      idInteres: idInteres ?? this.idInteres,
      nombreInteres: nombreInteres ?? this.nombreInteres,
      // Último mensaje
      direccionMensaje: direccionMensaje ?? this.direccionMensaje,
      fechaHora: fechaHora ?? this.fechaHora,

      // IBS
      isDerivadoIA: isDerivadoIA ?? this.isDerivadoIA,
      // Fecha del primer mensaje del cliente
      fcPrimerMensajeCliente:
          fcPrimerMensajeCliente ?? this.fcPrimerMensajeCliente,
      // Último mensaje del CLIENTE
      tipoCliente: tipoCliente ?? this.tipoCliente,
      contenidoCliente: contenidoCliente ?? this.contenidoCliente,
      // Documento del último mensaje del CLIENTE
      archivoNombreCliente: archivoNombreCliente ?? this.archivoNombreCliente,
      archivoTipoCliente: archivoTipoCliente ?? this.archivoTipoCliente,

      // Cantidad de mensajes de la ia
      cantidadMensajesIA: cantidadMensajesIA ?? this.cantidadMensajesIA,
      fcUltimoMensajeIA: fcUltimoMensajeIA ?? this.fcUltimoMensajeIA,

      // ID Chat Cab
      idChatCab: idChatCab ?? this.idChatCab,
    );
  }
}
