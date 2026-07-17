import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/cart/domain/entities/cart_item_entity.dart';

void main() {
  group('CartItemEntity', () {
    test('creates with required fields', () {
      final item = CartItemEntity(
        id: 'ci1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        quantity: 2,
      );
      expect(item.totalPrice, 200.0);
      expect(item.totalOriginalPrice, null);
    });

    test('totalOriginalPrice returns correct value', () {
      final item = CartItemEntity(
        id: 'ci1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        originalPrice: 150.0,
        quantity: 3,
      );
      expect(item.totalPrice, 300.0);
      expect(item.totalOriginalPrice, 450.0);
    });

    test('defaults to isAvailable true', () {
      final item = CartItemEntity(
        id: 'ci1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        quantity: 1,
      );
      expect(item.isAvailable, true);
    });
  });
}
