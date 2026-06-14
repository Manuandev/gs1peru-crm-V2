// lib/features/lead/domain/entities/lead.dart

class Lead {
  final int idLead;
  final String nombre;
  final String apellido;
  final String nombreEmpresa;
  final String telefono;
  final bool isFavorito;
  final String asignadoA;
  final String fechaHora;
  final String idEstado;
  final String estado;
  final int? idEvento;
  final String? evento;
  final int idCampania;
  final String? campania;
  final int idCanal;
  final String? canal;
  final int? idInteres;
  final String? interes;
  final bool ibChat;

  String get nombreCompleto => '$nombre $apellido'.trim();

  const Lead({
    required this.idLead,
    required this.nombre,
    required this.apellido,
    required this.nombreEmpresa,
    required this.telefono,
    required this.isFavorito,
    required this.asignadoA,
    required this.fechaHora,
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
    String? nombre,
    String? apellido,
    String? nombreEmpresa,
    String? telefono,
    bool? isFavorito,
    String? asignadoA,
    String? fechaHora,
    String? idEstado,
    String? estado,
    int? idEvento,
    String? evento,
    int? idCampania,
    String? campania,
    int? idCanal,
    String? canal,
    int? idInteres,
    String? interes,
    bool? ibChat,
  }) {
    return Lead(
      idLead: idLead ?? this.idLead,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      telefono: telefono ?? this.telefono,
      isFavorito: isFavorito ?? this.isFavorito,
      asignadoA: asignadoA ?? this.asignadoA,
      fechaHora: fechaHora ?? this.fechaHora,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      idEvento: idEvento ?? this.idEvento,
      evento: evento ?? this.evento,
      idCampania: idCampania ?? this.idCampania,
      campania: campania ?? this.campania,
      idCanal: idCanal ?? this.idCanal,
      canal: canal ?? this.canal,
      idInteres: idInteres ?? this.idInteres,
      interes: interes ?? this.interes,
      ibChat: ibChat ?? this.ibChat,
    );
  }
}
