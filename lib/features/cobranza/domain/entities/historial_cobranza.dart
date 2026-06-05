// lib/features/cobranza/domain/entities/historial_cobranza.dart

class HistorialCobranza {
  final String idTipo;      // 'registro' | 'estado' | 'recordatorio' | 'pago'
  final String titulo;
  final String descripcion;
  final String fecha;
  final String hora;
  final String ejecutivo;

  const HistorialCobranza({
    required this.idTipo,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.ejecutivo,
  });
}
