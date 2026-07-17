import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dateOnly = DateFormat('yyyy/MM/dd');
  static final _dateTime = DateFormat('dd/MM/yyyy - HH:mm');

  static String dateOnly(DateTime date) => _dateOnly.format(date);
  static String dateTime(DateTime date) => _dateTime.format(date);
}
