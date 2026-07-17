import '../entities/cart_item_entity.dart';

abstract class ICartRepository {
  Stream<List<CartItemEntity>> watchCart(String userId);
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
  });
  Future<void> updateQuantity(String userId, String itemId, int quantity);
  Future<void> removeItem(String userId, String itemId);
  Future<void> clearCart(String userId);
  Future<bool> isInCart(String userId, String productId);
  Future<void> mergeGuestCart(String userId, List<CartItemEntity> items);
}
