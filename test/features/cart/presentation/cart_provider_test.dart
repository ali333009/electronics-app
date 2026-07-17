import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/features/cart/domain/entities/cart_item_entity.dart';
import 'package:elct/features/cart/domain/repositories/i_cart_repository.dart';
import 'package:elct/features/cart/presentation/providers/cart_provider.dart';
import 'package:elct/features/cart/presentation/providers/guest_cart_provider.dart';
import 'package:elct/features/auth/presentation/providers/auth_provider.dart';

class MockCartRepo implements ICartRepository {
  final List<CartItemEntity> items;

  MockCartRepo(this.items);

  @override
  Stream<List<CartItemEntity>> watchCart(String userId) => Stream.value(items);

  @override
  Future<void> addItem({
    required String userId,
    required String productId,
    required String nameAr,
    required String nameEn,
    required String image,
    required double price,
    double? originalPrice,
    int? discountPercent,
    int stockQuantity = 0,
    int quantity = 1,
    Map<String, String>? selectedOptions,
  }) async {}

  @override
  Future<void> updateQuantity(
    String userId,
    String itemId,
    int quantity,
  ) async {}

  @override
  Future<void> removeItem(String userId, String itemId) async {}

  @override
  Future<void> clearCart(String userId) async {}

  @override
  Future<bool> isInCart(String userId, String productId) async => false;

  @override
  Future<void> mergeGuestCart(
    String userId,
    List<CartItemEntity> items,
  ) async {}
}

final mockUserIdProvider = Provider<String?>((ref) => null);
final mockCartRepoProvider = Provider<ICartRepository>(
  (ref) => MockCartRepo([]),
);

void main() {
  group('cartTotalProvider', () {
    test('returns 0 for empty cart when not logged in', () {
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => null),
          cartRepositoryProvider.overrideWith((ref) => MockCartRepo([])),
        ],
      );
      addTearDown(() => container.dispose());
      expect(container.read(cartTotalProvider), 0.0);
    });
  });

  group('cartCountProvider', () {
    test('returns 0 for empty cart', () {
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => null),
          cartRepositoryProvider.overrideWith((ref) => MockCartRepo([])),
        ],
      );
      addTearDown(() => container.dispose());
      expect(container.read(cartCountProvider), 0);
    });
  });

  group('cartItemsProvider', () {
    test('returns guest cart items when not logged in', () {
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => null),
          cartRepositoryProvider.overrideWith((ref) => MockCartRepo([])),
        ],
      );
      addTearDown(() => container.dispose());
      final items = container.read(cartItemsProvider);
      expect(items.valueOrNull, []);
    });

    test('guest items are included in total', () {
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => null),
          cartRepositoryProvider.overrideWith((ref) => MockCartRepo([])),
        ],
      );
      addTearDown(() => container.dispose());

      container
          .read(guestCartProvider.notifier)
          .addItem(
            CartItemEntity(
              id: 'p1',
              productId: 'p1',
              nameAr: 'منتج',
              nameEn: 'P',
              image: 'img.jpg',
              price: 100.0,
              quantity: 2,
              stockQuantity: 10,
            ),
          );
      expect(container.read(cartTotalProvider), 200.0);
    });
  });
}
