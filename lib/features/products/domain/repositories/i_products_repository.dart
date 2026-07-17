import '../entities/product_entity.dart';

abstract class IProductsRepository {
  Future<List<ProductEntity>> getProducts({int limit, String? startAfterId});
  Future<List<ProductEntity>> getProductsByCategory(String categoryId, {String? startAfterId, int limit});
  Future<List<ProductEntity>> getFeaturedProducts();
  Future<List<ProductEntity>> getNewProducts();
  Future<List<ProductEntity>> getBestSellerProducts();
  Future<ProductEntity> getProductById(String id);
  Future<List<ProductEntity>> searchProducts(String query, {String? startAfterId, int limit});
  Future<List<ProductEntity>> getProductsByIds(List<String> ids);
}
