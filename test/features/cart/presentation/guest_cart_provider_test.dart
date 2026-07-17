import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/features/cart/presentation/providers/guest_cart_provider.dart';
import 'package:elct/features/cart/domain/entities/cart_item_entity.dart';

void main() {
  group('GuestCartNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('starts with empty cart', () {
      expect(container.read(guestCartProvider), []);
    });

    test('addItem adds new item', () {
      final item = CartItemEntity(
        id: 'p1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        quantity: 1,
        stockQuantity: 10,
      );
      container.read(guestCartProvider.notifier).addItem(item);
      expect(container.read(guestCartProvider).length, 1);
    });

    test('addItem increases quantity for existing item', () {
      final item = CartItemEntity(
        id: 'p1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        quantity: 1,
        stockQuantity: 10,
      );
      final notifier = container.read(guestCartProvider.notifier);
      notifier.addItem(item);
      notifier.addItem(item);
      expect(container.read(guestCartProvider).length, 1);
      expect(container.read(guestCartProvider).first.quantity, 2);
    });

    test('removeItem removes from cart', () {
      final item = CartItemEntity(
        id: 'p1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        quantity: 1,
        stockQuantity: 10,
      );
      final notifier = container.read(guestCartProvider.notifier);
      notifier.addItem(item);
      notifier.removeItem('p1');
      expect(container.read(guestCartProvider), []);
    });

    test('updateQuantity changes quantity', () {
      final item = CartItemEntity(
        id: 'p1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        quantity: 1,
        stockQuantity: 10,
      );
      final notifier = container.read(guestCartProvider.notifier);
      notifier.addItem(item);
      notifier.updateQuantity('p1', 5);
      expect(container.read(guestCartProvider).first.quantity, 5);
    });

    test('clear empties the cart', () {
      final item = CartItemEntity(
        id: 'p1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        quantity: 1,
        stockQuantity: 10,
      );
      final notifier = container.read(guestCartProvider.notifier);
      notifier.addItem(item);
      notifier.clear();
      expect(container.read(guestCartProvider), []);
    });
  });
}
