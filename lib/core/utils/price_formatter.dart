import 'package:intl/intl.dart';
import '../models/currency.dart';

String formatPrice(num price, Currency currency) {
  final converted = price * currency.rate;
  final formatter = NumberFormat('#,###.#', 'en_US');
  return '${formatter.format(converted)} ${currency.symbol}';
}

extension PriceFormatExtension on num {
  String formatPrice(Currency currency) {
    final converted = this * currency.rate;
    final formatter = NumberFormat('#,###.#', 'en_US');
    return '${formatter.format(converted)} ${currency.symbol}';
  }
}
