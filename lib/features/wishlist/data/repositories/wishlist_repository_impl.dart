import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/i_wishlist_repository.dart';
import '../datasources/wishlist_datasource.dart';
import '../models/wishlist_item_model.dart';

class WishlistRepositoryImpl implements IWishlistRepository {
  final WishlistDatasource _datasource;

  WishlistRepositoryImpl({WishlistDatasource? datasource})
    : _datasource = datasource ?? WishlistDatasource();

  @override
  Stream<List<WishlistItemEntity>> watchWishlist(String userId) {
    return _datasource.watchWishlist(userId).map(
        (models) => models.map((m) => m.toEntity()).toList());
  }

  @override
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
  }) async {
    final exists = await _datasource.isInWishlist(userId, productId);
    if (exists) {
      await _datasource.removeItem(userId, productId);
    } else {
      final model = WishlistItemModel(
        id: productId,
        userId: userId,
        productId: productId,
        nameAr: nameAr,
        nameEn: nameEn,
        image: image,
        price: price,
        originalPrice: originalPrice,
        discountPercent: discountPercent,
        rating: rating,
        reviewCount: reviewCount,
        stockQuantity: stockQuantity,
      );
      await _datasource.addItem(model);
    }
  }

  @override
  Future<bool> isInWishlist(String userId, String productId) async {
    return _datasource.isInWishlist(userId, productId);
  }

  @override
  Future<void> removeItem(String userId, String productId) async {
    await _datasource.removeItem(userId, productId);
  }
}
