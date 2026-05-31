// lib\features\home\domain\entities\notifications\recordatorio.dart

class Recordatorio {
  final int idLead;
  final String nombre;
  final String nombreEmpresa;
  final String telefono;
  final String asignadoA;
  final String comentario;
  final String accion;
  final String aviso;
  final String fechaHora;
  final String idCampania;
  final String campania;
  final String idEvento;
  final String evento;
  final String idCanal;
  final String canal;

  const Recordatorio({
    required this.idLead,
    required this.nombre,
    required this.nombreEmpresa,
    required this.telefono,
    required this.asignadoA,
    required this.comentario,
    required this.accion,
    required this.aviso,
    required this.fechaHora,
    required this.idCampania,
    required this.campania,
    required this.idEvento,
    required this.evento,
    required this.idCanal,
    required this.canal,
  });
}
