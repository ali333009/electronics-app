import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_products_repository.dart';
import '../datasources/products_datasource.dart';
import '../models/product_model.dart';

class ProductsRepositoryImpl implements IProductsRepository {
  final ProductsDatasource _datasource;

  ProductsRepositoryImpl({ProductsDatasource? datasource})
    : _datasource = datasource ?? ProductsDatasource();

  @override
  Future<List<ProductEntity>> getProducts({int limit = 20, String? startAfterId}) async {
    final models = await _datasource.getProducts(limit: limit, startAfterId: startAfterId);
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId, {String? startAfterId, int limit = 11}) async {
    final models = await _datasource.getProductsByCategory(categoryId, startAfterId: startAfterId, limit: limit);
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<ProductEntity>> getFeaturedProducts() async {
    final models = await _datasource.getFeaturedProducts();
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<ProductEntity>> getNewProducts() async {
    final models = await _datasource.getNewProducts();
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<ProductEntity>> getBestSellerProducts() async {
    final models = await _datasource.getBestSellerProducts();
    return models.map(_toEntity).toList();
  }

  @override
  Future<ProductEntity> getProductById(String id) async {
    final model = await _datasource.getProductById(id);
    return _toEntity(model);
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query, {String? startAfterId, int limit = 11}) async {
    final models = await _datasource.searchProducts(query, startAfterId: startAfterId, limit: limit);
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<ProductEntity>> getProductsByIds(List<String> ids) async {
    final models = await _datasource.getProductsByIds(ids);
    return models.map(_toEntity).toList();
  }

  ProductEntity _toEntity(ProductModel m) => m.toEntity();
}
