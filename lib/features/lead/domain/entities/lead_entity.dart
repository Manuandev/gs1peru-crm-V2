// lib/features/lead/domain/entities/lead_entity.dart

abstract class LeadEntity {
  const LeadEntity();

  int get idLead;
  String get nombre;
  String get apellido;
  String get nombreEmpresa;
  String get telefono;
  bool get isFavorito;
  String get asignadoA;
  String get idEstado;
  String get estado;
  int? get idEvento;
  String? get evento;
  int? get idCampania;
  String? get campania;
  int? get idCanal;
  String? get canal;
  int? get idInteres;
  String? get interes;
  String get fechaHora;

  String get nombreCompleto => '$nombre $apellido'.trim();

  LeadEntity copyWith({
    int? idLead,
    String? nombre,
    String? apellido,
    String? nombreEmpresa,
    String? telefono,
    bool? isFavorito,
    String? asignadoA,
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
    String? fechaHora,
  });
}