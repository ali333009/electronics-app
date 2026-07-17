import 'package:flutter_test/flutter_test.dart';
import 'package:elct/core/utils/price_formatter.dart';
import 'package:elct/core/models/currency.dart';

void main() {
  group('formatPrice', () {
    test('formats integer price with KWD', () {
      expect(formatPrice(100, Currency.available.first), '100 KWD');
    });

    test('formats price with thousands separator', () {
      expect(formatPrice(1500, Currency.available.first), '1,500 KWD');
    });

    test('formats double price (rounded to integer)', () {
      expect(formatPrice(99.99, Currency.available.first), '100 KWD');
    });

    test('formats zero', () {
      expect(formatPrice(0, Currency.available.first), '0 KWD');
    });

    test('formats large number', () {
      expect(formatPrice(1000000, Currency.available.first), '1,000,000 KWD');
    });

    test('formats negative price', () {
      expect(formatPrice(-50, Currency.available.first), '-50 KWD');
    });

    test('formats with specified currency', () {
      final usd = Currency.fromCode('USD');
      expect(formatPrice(100, usd), '330 USD');
    });
  });

  group('PriceFormatExtension', () {
    test('formats with currency extension', () {
      final usd = Currency.fromCode('USD');
      expect(100.formatPrice(usd), '330 USD');
    });

    test('formats with SAR currency', () {
      final sar = Currency.fromCode('SAR');
      expect(50.formatPrice(sar), '619 SAR');
    });
  });
}
