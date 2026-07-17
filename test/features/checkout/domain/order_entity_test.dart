import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/checkout/domain/entities/order_entity.dart';

void main() {
  group('OrderItemEntity', () {
    test('total calculates correctly', () {
      final item = OrderItemEntity(
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        quantity: 3,
      );
      expect(item.total, 300.0);
    });
  });

  group('ShippingAddressEntity', () {
    test('creates with required fields', () {
      final addr = ShippingAddressEntity(
        name: 'User',
        phone: '+96550000000',
        address: 'Street',
        city: 'Kuwait',
      );
      expect(addr.label, null);
    });
  });

  group('OrderEntity', () {
    test('creates with required fields', () {
      final addr = ShippingAddressEntity(
        name: 'User',
        phone: '+96550000000',
        address: 'Street',
        city: 'Kuwait',
      );
      final order = OrderEntity(
        id: 'o1',
        items: [],
        subtotal: 100.0,
        total: 105.0,
        status: OrderStatus.pending,
        shippingAddress: addr,
        createdAt: DateTime(2025, 1, 1),
      );
      expect(order.paymentMethod, 'cod');
      expect(order.shipping, 0);
    });
  });

  group('OrderStatus', () {
    test('has all expected values', () {
      expect(OrderStatus.values, [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.shipped,
        OrderStatus.delivered,
        OrderStatus.cancelled,
      ]);
    });
  });
}
