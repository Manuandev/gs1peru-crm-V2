// lib/core/utils/date/date_formatter.dart
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class DateFormatter {
  static bool _initialized = false;

  /// Inicializa locales una sola vez
  static Future<void> initialize({String locale = 'es'}) async {
    if (!_initialized) {
      await initializeDateFormatting(locale);
      _initialized = true;
    }
  }

  /// Método principal
  static String format({
    required DateTime date,
    required AppDateFormat format,
    String locale = 'es',
  }) {
    final pattern = _resolvePattern(format);
    return DateFormat(pattern, locale).format(date);
  }

  /// Soporte cuando viene string del backend
  static String formatFromString({
    required String dateString,
    required AppDateFormat dateFormat,
    String locale = 'es',
  }) {
    try {
      final date = parseDate(dateString.trim());
      if (date == null) return '';
      return format(date: date, format: dateFormat, locale: locale);
    } catch (_) {
      return '';
    }
  }

  // Agrega este método privado:
  static DateTime? parseDate(String dateString) {
    // Formato estándar: "2025-02-04 16:49:17.000"
    try {
      return DateTime.parse(dateString);
    } catch (_) {}

    // Formato SQL Server: "Mar 29 2025 11:39AM" o "Mar 27 2025  1:07AM"
    try {
      final cleaned = dateString.replaceAll(RegExp(r'\s+'), ' ').trim();
      return DateFormat('MMM d yyyy h:mma', 'en').parse(cleaned);
    } catch (_) {}

    // Formato solo hora: "10:49" o "10:49:12"
    final timeRegex = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$');
    final match = timeRegex.firstMatch(dateString.trim());
    if (match != null) {
      final now = DateTime.now();
      final h = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      final s = match.group(3) != null ? int.parse(match.group(3)!) : 0;
      return DateTime(now.year, now.month, now.day, h, m, s);
    }

    return null;
  }

  // ─── Nuevo método público ──────────────────────────────────────
  /// Formato estilo WhatsApp:
  /// Hoy     → "20:24"
  /// Ayer    → "Ayer"
  /// <7 días → "miércoles"
  /// Resto   → "26/03/2025"
  static String formatWhatsApp(String dateString, {String locale = 'es'}) {
    if (dateString.isEmpty) return '';
    final fecha = parseDate(dateString.trim());
    if (fecha == null) return '';

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final diaFecha = DateTime(fecha.year, fecha.month, fecha.day);
    final diferencia = hoy.difference(diaFecha).inDays;

    if (diferencia == 0) {
      return format(
        date: fecha,
        format: AppDateFormat.hourMinute,
        locale: locale,
      );
    }
    if (diferencia == 1) return 'Ayer';
    if (diferencia < 7) {
      return format(
        date: fecha,
        format: AppDateFormat.weekdayOnly,
        locale: locale,
      );
    }
    return format(date: fecha, format: AppDateFormat.shortDate, locale: locale);
  }

  static String formatWhatsAppMultimedia(
    String dateString, {
    String locale = 'es',
  }) {
    if (dateString.isEmpty) return '';
    final fecha = parseDate(dateString.trim());
    if (fecha == null) return '';

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final diaFecha = DateTime(fecha.year, fecha.month, fecha.day);
    final diferencia = hoy.difference(diaFecha).inDays;

    final hora = format(
      date: fecha,
      format: AppDateFormat.hourMinute,
      locale: locale,
    );

    if (diferencia == 0) {
      return 'Hoy - $hora';
    }
    if (diferencia == 1) {
      return 'Ayer - $hora';
    }
    if (diferencia < 7) {
      // "miércoles 20:24"
      final diaSemana = format(
        date: fecha,
        format: AppDateFormat.weekdayOnly,
        locale: locale,
      );
      return '$diaSemana - $hora';
    }
    // "26/03/2025 20:24"
    final fechaCorta = format(
      date: fecha,
      format: AppDateFormat.shortDate,
      locale: locale,
    );
    return '$fechaCorta - $hora';
  }

  /// Hoy        → "Hoy 10:22"
  /// Ayer       → "Ayer 10:22"
  /// Esta semana → "miércoles 10:22"
  /// Más antiguo → "26/03/2025"
  static String formatConDia(String dateString, {String locale = 'es'}) {
    if (dateString.isEmpty) return '';
    final fecha = parseDate(dateString.trim());
    if (fecha == null) return '';

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final diaFecha = DateTime(fecha.year, fecha.month, fecha.day);
    final diferencia = hoy.difference(diaFecha).inDays;

    final hora = format(
      date: fecha,
      format: AppDateFormat.hourMinute,
      locale: locale,
    );

    if (diferencia == 0) return 'Hoy $hora';
    if (diferencia == 1) return 'Ayer $hora';
    if (diferencia < 7) {
      final diaSemana = format(
        date: fecha,
        format: AppDateFormat.weekdayOnly,
        locale: locale,
      );
      return '$diaSemana $hora';
    }
    return format(date: fecha, format: AppDateFormat.shortDate, locale: locale);
  }

  /// Hoy        → "10:22"
  /// Ayer       → "Ayer 10:22"
  /// Esta semana → "miércoles 10:22"
  /// Más antiguo → "26/03/2025"
  /// Separador de fecha en lista de mensajes (estilo WhatsApp):
  /// Hoy        → "Hoy"
  /// Ayer       → "Ayer"
  /// < 7 días   → nombre del día de la semana (ej. "miércoles")
  /// Más antiguo → "d de MMMM yyyy"  (ej. "27 de marzo 2025")
  static String formatDateSeparator(String dateString, {String locale = 'es'}) {
    if (dateString.isEmpty) return '';
    final fecha = parseDate(dateString.trim());
    if (fecha == null) return '';

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final diaFecha = DateTime(fecha.year, fecha.month, fecha.day);
    final diferencia = hoy.difference(diaFecha).inDays;

    if (diferencia == 0) return 'Hoy';
    if (diferencia == 1) return 'Ayer';
    if (diferencia < 7) {
      return format(date: fecha, format: AppDateFormat.weekdayOnly, locale: locale);
    }
    return format(date: fecha, format: AppDateFormat.longDate, locale: locale);
  }

  static String formatSinHoy(String dateString, {String locale = 'es'}) {
    if (dateString.isEmpty) return '';
    final fecha = parseDate(dateString.trim());
    if (fecha == null) return '';

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final diaFecha = DateTime(fecha.year, fecha.month, fecha.day);
    final diferencia = hoy.difference(diaFecha).inDays;

    final hora = format(
      date: fecha,
      format: AppDateFormat.hourMinute,
      locale: locale,
    );

    if (diferencia == 0) return hora;
    if (diferencia == 1) return 'Ayer $hora';
    if (diferencia < 7) {
      final diaSemana = format(
        date: fecha,
        format: AppDateFormat.weekdayOnly,
        locale: locale,
      );
      return '$diaSemana $hora';
    }
    return format(date: fecha, format: AppDateFormat.shortDate, locale: locale);
  }

  static String _resolvePattern(AppDateFormat format) {
    switch (format) {
      case AppDateFormat.hourMinute:
        return 'HH:mm';

      case AppDateFormat.hourMinuteSecond:
        return 'HH:mm:ss';

      case AppDateFormat.shortDate:
        return 'dd/MM/yyyy';

      case AppDateFormat.longDate:
        return "d 'de' MMMM yyyy";

      case AppDateFormat.fullTextDate:
        return "EEEE d 'de' MMMM 'del' yyyy";

      case AppDateFormat.weekdayOnly:
        return 'EEEE';

      case AppDateFormat.monthOnly:
        return 'MMMM';
      case AppDateFormat.whatsapp:
        return '';
    }
  }
}


// EJEMPLOS
// const fecha = "2025-03-27 01:07:41.677";

// // ⏰ Solo hora y minuto
// fecha.formatDate(AppDateFormat.hourMinute);
// // → "01:07"

// // ⏱️ Hora, minuto y segundo
// fecha.formatDate(AppDateFormat.hourMinuteSecond);
// // → "01:07:41"

// // 📅 Fecha corta
// fecha.formatDate(AppDateFormat.shortDate);
// // → "27/03/2025"

// // 📆 Fecha larga
// fecha.formatDate(AppDateFormat.longDate);
// // → "27 de marzo 2025"

// // 📋 Fecha completa en texto
// fecha.formatDate(AppDateFormat.fullTextDate);
// // → "jueves 27 de marzo del 2025"

// // 📌 Solo día de la semana
// fecha.formatDate(AppDateFormat.weekdayOnly);
// // → "jueves"

// // 🗓️ Solo mes
// fecha.formatDate(AppDateFormat.monthOnly);
// // → "marzo"