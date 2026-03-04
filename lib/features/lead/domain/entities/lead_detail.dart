// lib\features\lead\domain\entities\lead_detail.dart

class LeadDetail {
  final String idCreacion; // 00 - ID_CREACION
  final String documento; // 01 - RUC o NRO_DOC
  final String nombre; // 02 - Nombre empresa o persona
  final String telefono; // 03 - TELEFONO_1
  final String correo; // 04 - CORREO_1
  final String oportunidad; // 05 - NOMBRE oportunidad

  const LeadDetail({
    required this.idCreacion,
    required this.documento,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.oportunidad,
  });
}
