import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/i_cart_repository.dart';
import '../datasources/cart_datasource.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements ICartRepository {
  final CartDatasource _datasource;

  CartRepositoryImpl({CartDatasource? datasource})
    : _datasource = datasource ?? CartDatasource();

  @override
  Stream<List<CartItemEntity>> watchCart(String userId) {
    return _datasource.watchCart(userId).map(
        (models) => models.map((m) => m.toEntity()).toList());
  }

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
  }) async {
    if (stockQuantity <= 0) {
      throw StateError('OUT_OF_STOCK');
    }
    // Build a unique cart item ID that includes the selectedOptions hash
    // so the same product with different options is a separate cart entry
    String cartItemId = productId;
    if (selectedOptions != null && selectedOptions.isNotEmpty) {
      final sortedPairs = (selectedOptions.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)))
          .map((e) => '${e.key}=${e.value}')
          .join(',');
      final hash = sortedPairs.hashCode.abs().toString();
      cartItemId = '${productId}_$hash';
    }
    // ignore: avoid_print
    print('[CART] addItem: productId=$productId, cartItemId=$cartItemId, selectedOptions=$selectedOptions');

    final existing = await _datasource.getItemByProductId(userId, cartItemId);
    if (existing != null) {
      final newQuantity =
          (existing.quantity + quantity).clamp(1, stockQuantity).toInt();
      await _datasource.updateQuantity(
          userId, existing.id, newQuantity);
      // Also update selectedOptions in case they changed
      if (selectedOptions != null) {
        await _datasource.updateOptions(userId, existing.id, selectedOptions);
      }
      return;
    }
    final model = CartItemModel(
      id: cartItemId,
      userId: userId,
      productId: productId,
      nameAr: nameAr,
      nameEn: nameEn,
      image: image,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      quantity: quantity.clamp(1, stockQuantity).toInt(),
      stockQuantity: stockQuantity,
      isAvailable: stockQuantity > 0,
      selectedOptions: selectedOptions,
    );
    // ignore: avoid_print
    print('[CART] Saving new item to Firestore: id=$cartItemId, options=$selectedOptions');
    await _datasource.addItem(model);
  }

  @override
  Future<void> updateQuantity(
      String userId, String itemId, int quantity) async {
    if (quantity <= 0) {
      await _datasource.removeItem(userId, itemId);
      return;
    }
    final existing = await _datasource.getItemByProductId(userId, itemId);
    if (existing != null && existing.stockQuantity > 0) {
      final cappedQuantity =
          quantity.clamp(1, existing.stockQuantity).toInt();
      await _datasource.updateQuantity(userId, itemId, cappedQuantity);
      return;
    }
    await _datasource.updateQuantity(userId, itemId, quantity);
  }

  @override
  Future<void> removeItem(String userId, String itemId) async {
    await _datasource.removeItem(userId, itemId);
  }

  @override
  Future<void> clearCart(String userId) async {
    await _datasource.clearCart(userId);
  }

  @override
  Future<void> mergeGuestCart(String userId, List<CartItemEntity> items) async {
    for (final item in items) {
      await addItem(
        userId: userId,
        productId: item.productId,
        nameAr: item.nameAr,
        nameEn: item.nameEn,
        image: item.image,
        price: item.price,
        originalPrice: item.originalPrice,
        discountPercent: item.discountPercent,
        stockQuantity: item.stockQuantity,
        quantity: item.quantity,
        selectedOptions: item.selectedOptions,
      );
    }
  }

  @override
  Future<bool> isInCart(String userId, String productId) async {
    final item = await _datasource.getItemByProductId(userId, productId);
    return item != null;
  }
}
