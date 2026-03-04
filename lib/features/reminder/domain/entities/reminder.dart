class Reminder {
  final String idRecordatorio; // 00 - ID_RECORDATORIO
  final String fecha; // 01 - FCH_CREACION
  final String hora; // 02 - HORA
  final String accion; // 03 - Enviar WhatsApp, Enviar correo
  final String aviso; // 04 - 5 minutos antes
  final String modalidad; // 05 - test
  final String fechaHora; // 06 - FECHA Y HORA: 25/10/2024 - 19:48
  final String comentario; // 07 - nota recordatorio
  final String nomApe; // 08 - Nombres y apellidos

  const Reminder({
    required this.idRecordatorio,
    required this.fecha,
    required this.hora,
    required this.accion,
    required this.aviso,
    required this.modalidad,
    required this.fechaHora,
    required this.comentario,
    required this.nomApe,
  });
}
