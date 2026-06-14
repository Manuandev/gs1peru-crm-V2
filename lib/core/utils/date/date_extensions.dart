// lib/core/utils/date/date_extensions.dart
import 'date_formatter.dart';
import 'date_formats.dart';

extension DateTimeFormatting on DateTime {
  String format(AppDateFormat format) {
    return DateFormatter.format(date: this, format: format);
  }

  String formatWhatsApp() {
    return DateFormatter.formatWhatsApp(toIso8601String());
  }

  String formatConDia() {
    return DateFormatter.formatConDia(toIso8601String());
  }

  String formatSinHoy() {
    return DateFormatter.formatSinHoy(toIso8601String());
  }
}

extension StringDateFormatting on String {
  String formatDate(AppDateFormat format) {
    return DateFormatter.formatFromString(dateString: this, dateFormat: format);
  }

  String formatWhatsApp() {
    return DateFormatter.formatWhatsApp(this);
  }

  String formatWhatsAppMultimedia() {
    return DateFormatter.formatWhatsAppMultimedia(this);
  }

  String formatConDia() {
    return DateFormatter.formatConDia(this);
  }

  String formatSinHoy() {
    return DateFormatter.formatSinHoy(this);
  }

  /// Separador de fecha en lista de mensajes WhatsApp:
  /// "Hoy" / "Ayer" / nombre del día / "d de MMMM yyyy"
  String formatDateSeparator() {
    return DateFormatter.formatDateSeparator(this);
  }
}
