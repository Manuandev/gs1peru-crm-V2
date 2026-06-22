// lib/features/chat/domain/entities/chat.dart

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
  final String idEstadoPadre;
  final String idEstadoDescripcion;
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
  // Último mensaje
  final String idTokenMeta;
  final String tipo;
  final String direccionMensaje; // AIA - ASISTENTE IA  / ASE - ASESOR / CLI - CLIENTE
  final String contenido;
  final String estadoEntrega;
  final String fechaHora;
  // Documento si tiene
  final String archivoNombre;
  final String archivoTipo;

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
    required this.idEstadoPadre,
    required this.idEstadoDescripcion,
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
    idEstadoPadre,
    idEstadoDescripcion,
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
    bool? isExpirado,
    bool? isCerrado,
    int? idLead,
    String? modalidad,
    String? idEstado,
    String? idEstadoPadre,
    String? idEstadoDescripcion,
    int? idCampania,
    String? nombreCampania,
    int? idOportunidad,
    String? nombreOportunidad,
    int? idCanal,
    String? nombreCanal,
    int? idInteres,
    String? nombreInteres,
    String? idTokenMeta,
    String? tipo,
    String? direccionMensaje,
    String? contenido,
    String? estadoEntrega,
    String? fechaHora,
    String? archivoNombre,
    String? archivoTipo,
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
      idEstadoPadre: idEstadoPadre ?? this.idEstadoPadre,
      idEstadoDescripcion: idEstadoDescripcion ?? this.idEstadoDescripcion,
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
    );
  }
}
