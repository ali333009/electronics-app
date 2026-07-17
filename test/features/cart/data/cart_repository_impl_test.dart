import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:elct/features/cart/data/models/cart_item_model.dart';
import 'package:elct/features/cart/domain/entities/cart_item_entity.dart';
import '../../../helpers/mock_datasources.dart';

void main() {
  group('CartRepositoryImpl', () {
    late MockCartDatasource mockDs;
    late CartRepositoryImpl repository;

    setUp(() {
      mockDs = MockCartDatasource();
      repository = CartRepositoryImpl(datasource: mockDs);
    });

    test('watchCart returns stream of cart items', () {
      mockDs.items = [
        CartItemModel(
          id: 'c1',
          userId: 'u1',
          productId: 'p1',
          nameAr: 'منتج',
          nameEn: 'P',
          image: 'img.jpg',
          price: 100,
          quantity: 2,
        ),
      ];
      final stream = repository.watchCart('u1');
      expect(stream, emits(isA<List<CartItemEntity>>()));
    });

    test('addItem adds new item to cart', () async {
      await repository.addItem(
        userId: 'u1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        stockQuantity: 10,
        quantity: 1,
      );
      expect(mockDs.items.length, 1);
    });

    test('addItem updates quantity if item exists', () async {
      mockDs.existingItem = CartItemModel(
        id: 'p1',
        userId: 'u1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'P',
        image: 'img.jpg',
        price: 100,
        quantity: 1,
        stockQuantity: 10,
      );
      mockDs.items = [mockDs.existingItem!];

      await repository.addItem(
        userId: 'u1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
        stockQuantity: 10,
        quantity: 2,
      );
      expect(mockDs.items.length, 1);
    });

    test('updateQuantity removes item if quantity <= 0', () async {
      mockDs.items = [
        CartItemModel(
          id: 'c1',
          userId: 'u1',
          productId: 'p1',
          nameAr: 'منتج',
          nameEn: 'P',
          image: 'img.jpg',
          price: 100,
          quantity: 1,
        ),
      ];
      await repository.updateQuantity('u1', 'c1', 0);
      expect(mockDs.items.length, 0);
    });

    test('removeItem removes from cart', () async {
      mockDs.items = [
        CartItemModel(
          id: 'c1',
          userId: 'u1',
          productId: 'p1',
          nameAr: 'منتج',
          nameEn: 'P',
          image: 'img.jpg',
          price: 100,
          quantity: 1,
        ),
      ];
      await repository.removeItem('u1', 'c1');
      expect(mockDs.items.length, 0);
    });

    test('clearCart empties the cart', () async {
      mockDs.items = [
        CartItemModel(
          id: 'c1',
          userId: 'u1',
          productId: 'p1',
          nameAr: 'منتج',
          nameEn: 'P',
          image: 'img.jpg',
          price: 100,
          quantity: 1,
        ),
      ];
      await repository.clearCart('u1');
      expect(mockDs.items.length, 0);
    });

    test('mergeGuestCart adds guest items', () async {
      final guestItems = [
        CartItemEntity(
          id: 'g1',
          productId: 'gp1',
          nameAr: 'منتج ضيف',
          nameEn: 'Guest',
          image: 'img.jpg',
          price: 50,
          quantity: 1,
          stockQuantity: 10,
        ),
      ];
      await repository.mergeGuestCart('u1', guestItems);
      expect(mockDs.items.length, 1);
    });
  });
}
