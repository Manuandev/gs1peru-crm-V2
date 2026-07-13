// lib/features/cobranza/presentation/utils/fecha_corta_utils.dart

// DateFormatter.parseDate (core) solo entiende ISO ("yyyy-MM-dd...") o el
// formato de SQL Server ("Mar 29 2025 11:39AM") — NUNCA 'dd/MM/yyyy', que es
// justo el formato que produce AppDateFormat.shortDate y que usa todo el
// plan de crédito (fechaVencimiento de cada cuota). Con DateFormatter.parseDate
// esas fechas siempre devuelven null. Parser manual para ese caso puntual.
DateTime? parseFechaCorta(String fecha) {
  final partes = fecha.split('/');
  if (partes.length != 3) return null;
  final dia = int.tryParse(partes[0]);
  final mes = int.tryParse(partes[1]);
  final anio = int.tryParse(partes[2]);
  if (dia == null || mes == null || anio == null) return null;
  return DateTime(anio, mes, dia);
}

// Días entre hoy y una fecha 'dd/MM/yyyy' (solo fecha, sin hora).
int diasDesdeHoy(String fecha) {
  final parsed = parseFechaCorta(fecha);
  if (parsed == null) return 0;
  final hoy = DateTime.now();
  final soloHoy = DateTime(hoy.year, hoy.month, hoy.day);
  return parsed.difference(soloHoy).inDays;
}
