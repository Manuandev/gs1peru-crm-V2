// lib/features/cobranza/domain/entities/historial_cobranza.dart

class HistorialCobranza {
  final String origen; // LA.ORIGEN — canal/origen de la actividad
  final String titulo; // LA.NOMBRE — nombre de la actividad
  final String descripcion; // LS.DESCRIPCION — detalle del seguimiento
  // Fecha+hora crudas del backend ('yyyy-MM-dd HH:mm:ss') — formatear en la
  // UI con las extensions de core (formatDate(AppDateFormat.shortDate) /
  // formatDate(AppDateFormat.hourMinute)), no separadas desde el backend.
  final String fecha;

  const HistorialCobranza({
    required this.origen,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
  });
}
