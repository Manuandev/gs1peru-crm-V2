// lib\features\lead\domain\entities\lead.dart

class Lead {
  final String userCreacion; // 00 - ID_CREACION
  final String idLead; // 01 - ID_LEAD
  final String fecha; // 02 - FCH_CREACION
  final String dia; // 03 - Lunes, Martes...
  final String numDia; // 04 - día numérico
  final String mes; // 05 - Enero, Febrero...
  final String anho; // 06 - YEAR
  final String hora; // 07 - HH:mm
  final String dni; // 08 - DNI

  const Lead({
    required this.userCreacion,
    required this.idLead,
    required this.fecha,
    required this.dia,
    required this.numDia,
    required this.mes,
    required this.anho,
    required this.hora,
    required this.dni,
  });
}
