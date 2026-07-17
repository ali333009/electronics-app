import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:elct/features/wishlist/domain/repositories/i_wishlist_repository.dart';
import 'package:elct/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:elct/features/auth/presentation/providers/auth_provider.dart';

class MockWishlistRepo implements IWishlistRepository {
  final List<WishlistItemEntity> items;
  MockWishlistRepo(this.items);

  @override
  Stream<List<WishlistItemEntity>> watchWishlist(String userId) {
    return Stream.value(items);
  }

  @override
  Future<void> toggleItem({required String userId, required String productId, required String nameAr, required String nameEn, required String image, required double price, double? originalPrice, int? discountPercent, double rating = 0, int reviewCount = 0, int stockQuantity = 0}) async {}

  @override
  Future<bool> isInWishlist(String userId, String productId) async => items.any((i) => i.productId == productId);

  @override
  Future<void> removeItem(String userId, String productId) async {}
}

void main() {
  group('wishlistCountProvider', () {
    test('returns 0 when not logged in', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());
      expect(container.read(wishlistCountProvider), 0);
    });

    test('returns count from wishlist items stream', () async {
      final items = [
        WishlistItemEntity(id: 'w1', productId: 'p1', nameAr: 'منتج', nameEn: 'P', image: 'img.jpg', price: 100),
      ];
      final mockRepo = MockWishlistRepo(items);

      final container = ProviderContainer(overrides: [
        wishlistRepositoryProvider.overrideWith((ref) => mockRepo),
        currentUserIdProvider.overrideWith((ref) => 'user-1'),
      ]);
      addTearDown(() => container.dispose());

      await container.read(wishlistItemsProvider.future);
      expect(container.read(wishlistCountProvider), 1);
    });
  });
}
