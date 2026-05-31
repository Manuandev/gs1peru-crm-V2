// lib\features\home\domain\entities\notifications\leads_notificaciones.dart

class LeadReasignado {
  final int idLead;
  final String nombre;
  final String nombreEmpresa;
  final String telefono;
  final String asignadoA;
  final String fechaHora;
  final String idCampania;
  final String campania;
  final String idEvento;
  final String evento;
  final String idCanal;
  final String canal;

  const LeadReasignado({
    required this.idLead,
    required this.nombre,
    required this.nombreEmpresa,
    required this.telefono,
    required this.asignadoA,
    required this.fechaHora,
    required this.idCampania,
    required this.campania,
    required this.idEvento,
    required this.evento,
    required this.idCanal,
    required this.canal,
  });
}

class LeadNuevo {
  final int idLead;
  final String nombre;
  final String nombreEmpresa;
  final String telefono;
  final String asignadoA;
  final String fechaHora;
  final String idCampania;
  final String campania;
  final String idEvento;
  final String evento;
  final String idCanal;
  final String canal;

  const LeadNuevo({
    required this.idLead,
    required this.nombre,
    required this.nombreEmpresa,
    required this.telefono,
    required this.asignadoA,
    required this.fechaHora,
    required this.idCampania,
    required this.campania,
    required this.idEvento,
    required this.evento,
    required this.idCanal,
    required this.canal,
  });
}
