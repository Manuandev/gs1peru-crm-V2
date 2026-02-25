import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'date_formats.dart';

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
      final date = DateTime.parse(dateString);
      return format(date: date, format: dateFormat, locale: locale);
    } catch (_) {
      return '';
    }
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
    }
  }
}