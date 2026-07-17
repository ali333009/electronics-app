import '../entities/wishlist_item_entity.dart';

abstract class IWishlistRepository {
  Stream<List<WishlistItemEntity>> watchWishlist(String userId);
  Future<void> toggleItem({
    required String userId,
    required String productId,
    required String nameAr,
    required String nameEn,
    required String image,
    required double price,
    double? originalPrice,
    int? discountPercent,
    double rating = 0,
    int reviewCount = 0,
    int stockQuantity = 0,
  });
  Future<bool> isInWishlist(String userId, String productId);
  Future<void> removeItem(String userId, String productId);
}
