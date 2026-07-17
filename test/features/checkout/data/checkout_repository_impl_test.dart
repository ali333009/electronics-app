import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:elct/features/checkout/data/models/promo_code_model.dart';
import '../../../helpers/mock_datasources.dart';

void main() {
  group('CheckoutRepositoryImpl', () {
    late MockCheckoutDatasource mockDs;
    late CheckoutRepositoryImpl repository;

    setUp(() {
      mockDs = MockCheckoutDatasource();
      repository = CheckoutRepositoryImpl(datasource: mockDs);
    });

    test('placeOrder creates order and returns entity', () async {
      final order = await repository.placeOrder(
        orderId: 'order-new',
        userId: 'u1',
        items: [
          {'productId': 'p1', 'nameAr': 'منتج', 'nameEn': 'P',
           'image': 'img.jpg', 'price': 100.0, 'quantity': 2},
        ],
        subtotal: 200.0,
        shipping: 5.0,
        total: 205.0,
        shippingAddress: {'name': 'User', 'phone': '+965', 'address': 'St', 'city': 'KW'},
        paymentMethod: 'cod',
      );
      expect(order.id, 'order-new');
      expect(order.status.name, 'pending');
    });

    test('validatePromoCode returns null for invalid', () async {
      final promo = await repository.validatePromoCode('INVALID');
      expect(promo, null);
    });

    test('validatePromoCode returns entity for valid', () async {
      mockDs.promoCode = PromoCodeModel(code: 'SAVE20', discountPercent: 20.0);
      final promo = await repository.validatePromoCode('SAVE20');
      expect(promo, isNotNull);
      expect(promo!.code, 'SAVE20');
      expect(promo.discountPercent, 20.0);
    });
  });
}
