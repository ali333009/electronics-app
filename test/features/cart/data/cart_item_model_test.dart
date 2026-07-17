import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/cart/data/models/cart_item_model.dart';
import 'package:elct/features/cart/domain/entities/cart_item_entity.dart';

Map<String, dynamic> fullCartItemData() => {
  'id': 'cart-1',
  'userId': 'user-1',
  'productId': 'prod-1',
  'nameAr': 'منتج تجريبي',
  'nameEn': 'Test Product',
  'image': 'img.jpg',
  'price': 100.0,
  'originalPrice': 150.0,
  'discountPercent': 33,
  'quantity': 2,
  'stockQuantity': 50,
  'isAvailable': true,
};

void main() {
  group('CartItemModel fromFirestore', () {
    test('parses full data correctly', () {
      final model = CartItemModel.fromFirestore(fullCartItemData());
      expect(model.id, 'cart-1');
      expect(model.price, 100.0);
      expect(model.quantity, 2);
      expect(model.isAvailable, true);
    });

    test('handles missing fields with defaults', () {
      final model = CartItemModel.fromFirestore({});
      expect(model.id, '');
      expect(model.price, 0.0);
      expect(model.quantity, 1);
      expect(model.isAvailable, true);
    });
  });

  group('CartItemModel toFirestore', () {
    test('serializes correctly', () {
      final model = CartItemModel.fromFirestore(fullCartItemData());
      final data = model.toFirestore();
      expect(data['productId'], 'prod-1');
      expect(data['price'], 100.0);
    });
  });

  group('CartItemModel toEntity', () {
    test('converts to entity correctly', () {
      final model = CartItemModel.fromFirestore(fullCartItemData());
      final entity = model.toEntity();
      expect(entity, isA<CartItemEntity>());
      expect(entity.productId, 'prod-1');
    });
  });
}
