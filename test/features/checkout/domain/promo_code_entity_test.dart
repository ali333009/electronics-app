import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/checkout/domain/entities/promo_code_entity.dart';

void main() {
  group('PromoCodeEntity', () {
    test('creates with required fields', () {
      final promo = PromoCodeEntity(code: 'SAVE20', discountPercent: 20.0);
      expect(promo.code, 'SAVE20');
      expect(promo.discountPercent, 20.0);
    });
  });
}
