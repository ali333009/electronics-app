import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/checkout/data/models/order_model.dart';
import 'package:elct/features/checkout/domain/entities/order_entity.dart';

Map<String, dynamic> fullOrderData() => {
  'id': 'order-1',
  'userId': 'user-1',
  'items': [
    {'productId': 'p1', 'nameAr': 'منتج', 'nameEn': 'Product', 'image': 'img.jpg', 'price': 100.0, 'quantity': 2},
  ],
  'subtotal': 200.0,
  'shipping': 5.0,
  'total': 205.0,
  'status': 'pending',
  'shippingAddress': {
    'name': 'User', 'phone': '+96550000000', 'address': 'Street', 'city': 'Kuwait',
  },
  'paymentMethod': 'cod',
};

void main() {
  group('OrderModel fromFirestore', () {
    test('parses full order data correctly', () {
      final model = OrderModel.fromFirestore(fullOrderData());
      expect(model.id, 'order-1');
      expect(model.items.length, 1);
      expect(model.subtotal, 200.0);
      expect(model.status, 'pending');
    });

    test('handles missing fields with defaults', () {
      final model = OrderModel.fromFirestore({});
      expect(model.items, []);
      expect(model.subtotal, 0.0);
      expect(model.status, 'pending');
    });
  });

  group('OrderModel toEntity', () {
    test('converts to OrderEntity with pending status', () {
      final model = OrderModel.fromFirestore(fullOrderData());
      final entity = model.toEntity();
      expect(entity, isA<OrderEntity>());
      expect(entity.status, OrderStatus.pending);
    });

    test('parses order status correctly', () {
      final data = fullOrderData();
      data['status'] = 'delivered';
      final model = OrderModel.fromFirestore(data);
      expect(model.toEntity().status, OrderStatus.delivered);
    });
  });

  group('OrderItemModel', () {
    test('fromFirestore and toEntity work correctly', () {
      final item = OrderItemModel.fromFirestore({
        'productId': 'p1', 'nameAr': 'منتج', 'nameEn': 'P',
        'image': 'img.jpg', 'price': 100.0, 'quantity': 2,
      });
      final entity = item.toEntity();
      expect(entity.total, 200.0);
    });
  });
}
