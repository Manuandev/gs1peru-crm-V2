// lib/features/lead/domain/entities/lead.dart

class Lead {
  // Info contacto / lead
  final int idLead;
  final int idContacto;
  final String nombre;
  final String apellido;
  final String nombreEmpresa;
  final String asesor;
  final String fechaHora;
  // Info numero
  final int idNumero;
  final String prefijo;
  final String numero;
  final bool isFavorito;
  // Info correo
  final String correo;
  // Info estado
  final String idEstado;
  final String estado;
  // Info campaña
  final int idCampania;
  final String campania;
  // Info oportunidad
  final int idEvento;
  final String evento;
  // Info canal
  final int idCanal;
  final String canal;
  // Info interes
  final int idInteres;
  final String interes;
  // Conversacion abierta IB
  final bool ibChat;

  String get nombreCompleto => '$nombre $apellido'.trim();

  const Lead({
    required this.idLead,
    required this.idContacto,
    required this.nombre,
    required this.apellido,
    required this.nombreEmpresa,
    required this.asesor,
    required this.fechaHora,
    required this.idNumero,
    required this.prefijo,
    required this.numero,
    required this.isFavorito,
    required this.correo,
    required this.idEstado,
    required this.estado,
    required this.idCampania,
    required this.campania,
    required this.idEvento,
    required this.evento,
    required this.idCanal,
    required this.canal,
    required this.idInteres,
    required this.interes,
    required this.ibChat,
  });

  Lead copyWith({
    int? idLead,
    int? idContacto,
    String? nombre,
    String? apellido,
    String? nombreEmpresa,
    String? asesor,
    String? fechaHora,
    int? idNumero,
    String? prefijo,
    String? numero,
    bool? isFavorito,
    String? correo,
    String? idEstado,
    String? estado,
    int? idCampania,
    String? campania,
    int? idEvento,
    String? evento,
    int? idCanal,
    String? canal,
    int? idInteres,
    String? interes,
    bool? ibChat,
  }) {
    return Lead(
      idLead: idLead ?? this.idLead,
      idContacto: idContacto ?? this.idContacto,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      asesor: asesor ?? this.asesor,
      fechaHora: fechaHora ?? this.fechaHora,
      idNumero: idNumero ?? this.idNumero,
      prefijo: prefijo ?? this.prefijo,
      numero: numero ?? this.numero,
      isFavorito: isFavorito ?? this.isFavorito,
      correo: correo ?? this.correo,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      idCampania: idCampania ?? this.idCampania,
      campania: campania ?? this.campania,
      idEvento: idEvento ?? this.idEvento,
      evento: evento ?? this.evento,
      idCanal: idCanal ?? this.idCanal,
      canal: canal ?? this.canal,
      idInteres: idInteres ?? this.idInteres,
      interes: interes ?? this.interes,
      ibChat: ibChat ?? this.ibChat,
    );
  }
}
