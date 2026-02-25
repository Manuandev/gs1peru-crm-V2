import 'date_formatter.dart';
import 'date_formats.dart';

extension DateTimeFormatting on DateTime {

  String format(AppDateFormat format) {
    return DateFormatter.format(
      date: this,
      format: format,
    );
  }
}

extension StringDateFormatting on String {

  String formatDate(AppDateFormat format) {
    return DateFormatter.formatFromString(
      dateString: this,
      dateFormat: format,
    );
  }
}