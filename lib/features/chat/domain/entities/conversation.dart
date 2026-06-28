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
  final int idEmpresa;
  final String ruc;
  final String nombreEmpresa;
  final String direccionEmpresa;
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
  final String idTokenMeta;
  final String tipo;
  final String
  direccionMensaje; // AIA - ASISTENTE IA  / ASE - ASESOR / CLI - CLIENTE
  final String contenido;
  final String estadoEntrega;
  final String fechaHora;
  // Documento si tiene en General
  final String archivoNombre;
  final String archivoTipo;

  // IBS
  final bool isDerivadoIA;
  // Fecha del primer mensaje del cliente
  final String fcPrimerMensajeCliente;
  // Último mensaje del CLIENTE
  final String idTokenMetaCliente;
  final String tipoCliente;
  final String direccionCliente;
  final String contenidoCliente;
  final String estadoEntregaCliente;
  final String fcUsuarioCCliente;
  // Documento del último mensaje del CLIENTE
  final String archivoNombreCliente;
  final String archivoTipoCliente;

  /// Retorna el id del estado a mostrar en UI: padre si existe, directo si no.
  String get idEstadoEfectivo =>
      idEstadoPadre.isNotEmpty ? idEstadoPadre : idEstado;

  /// Retorna la descripción del estado efectivo.
  String get descEstadoEfectiva =>
      idEstadoPadre.isNotEmpty ? descEstadoPadre : descEstado;

  String get nombreCompleto =>
      '$nombres $apellidoPaterno $apellidoMaterno'.trim();

  const Chat({
    // Contacto
    required this.idContacto,
    required this.nombres,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.asesor,
    //Empresa
    required this.idEmpresa,
    required this.ruc,
    required this.nombreEmpresa,
    required this.direccionEmpresa,
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
    required this.idTokenMeta,
    required this.tipo,
    required this.direccionMensaje,
    required this.contenido,
    required this.estadoEntrega,
    required this.fechaHora,
    // Documento si tiene
    required this.archivoNombre,
    required this.archivoTipo,

    // IBS
    required this.isDerivadoIA,
    // Fecha del primer mensaje del cliente
    required this.fcPrimerMensajeCliente,
    // Último mensaje del CLIENTE
    required this.idTokenMetaCliente,
    required this.tipoCliente,
    required this.direccionCliente,
    required this.contenidoCliente,
    required this.estadoEntregaCliente,
    required this.fcUsuarioCCliente,
    // Documento del último mensaje del CLIENTE
    required this.archivoNombreCliente,
    required this.archivoTipoCliente,
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
    idEmpresa,
    ruc,
    nombreEmpresa,
    direccionEmpresa,
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
    idTokenMeta,
    tipo,
    direccionMensaje,
    contenido,
    estadoEntrega,
    fechaHora,
    // Documento si tiene
    archivoNombre,
    archivoTipo,
  ];

  Chat copyWith({
    int? idContacto,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? asesor,
    int? idEmpresa,
    String? ruc,
    String? nombreEmpresa,
    String? direccionEmpresa,
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
    String? idTokenMeta,
    String? tipo,
    String? direccionMensaje,
    String? contenido,
    String? estadoEntrega,
    String? fechaHora,
    // Documento si tiene
    String? archivoNombre,
    String? archivoTipo,

    // IBS
    bool? isDerivadoIA,
    // Fecha del primer mensaje del cliente
    String? fcPrimerMensajeCliente,
    // Último mensaje del CLIENTE
    String? idTokenMetaCliente,
    String? tipoCliente,
    String? direccionCliente,
    String? contenidoCliente,
    String? estadoEntregaCliente,
    String? fcUsuarioCCliente,
    // Documento del último mensaje del CLIENTE
    String? archivoNombreCliente,
    String? archivoTipoCliente,
  }) {
    return Chat(
      // Contacto
      idContacto: idContacto ?? this.idContacto,
      nombres: nombres ?? this.nombres,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      asesor: asesor ?? this.asesor,
      //Empresa
      idEmpresa: idEmpresa ?? this.idEmpresa,
      ruc: ruc ?? this.ruc,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      direccionEmpresa: direccionEmpresa ?? this.direccionEmpresa,
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
      idTokenMeta: idTokenMeta ?? this.idTokenMeta,
      tipo: tipo ?? this.tipo,
      direccionMensaje: direccionMensaje ?? this.direccionMensaje,
      contenido: contenido ?? this.contenido,
      estadoEntrega: estadoEntrega ?? this.estadoEntrega,
      fechaHora: fechaHora ?? this.fechaHora,
      // Documento si tiene
      archivoNombre: archivoNombre ?? this.archivoNombre,
      archivoTipo: archivoTipo ?? this.archivoTipo,

      // IBS
      isDerivadoIA: isDerivadoIA ?? this.isDerivadoIA,
      // Fecha del primer mensaje del cliente
      fcPrimerMensajeCliente:
          fcPrimerMensajeCliente ?? this.fcPrimerMensajeCliente,
      // Último mensaje del CLIENTE
      idTokenMetaCliente: idTokenMetaCliente ?? this.idTokenMetaCliente,
      tipoCliente: tipoCliente ?? this.tipoCliente,
      direccionCliente: direccionCliente ?? this.direccionCliente,
      contenidoCliente: contenidoCliente ?? this.contenidoCliente,
      estadoEntregaCliente: estadoEntregaCliente ?? this.estadoEntregaCliente,
      fcUsuarioCCliente: fcUsuarioCCliente ?? this.fcUsuarioCCliente,
      // Documento del último mensaje del CLIENTE
      archivoNombreCliente: archivoNombreCliente ?? this.archivoNombreCliente,
      archivoTipoCliente: archivoTipoCliente ?? this.archivoTipoCliente,
    );
  }
}
