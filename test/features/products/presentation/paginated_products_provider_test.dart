import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/products/presentation/providers/paginated_products_provider.dart';
import 'package:elct/features/products/domain/entities/product_entity.dart';
import 'package:elct/features/products/domain/repositories/i_products_repository.dart';

class MockProductsRepo implements IProductsRepository {
  final List<ProductEntity> products;

  MockProductsRepo(this.products);

  @override
  Future<List<ProductEntity>> getProducts({int limit = 20, String? startAfterId}) async {
    return products.take(limit).toList();
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId, {String? startAfterId, int limit = 11}) async {
    return products.take(limit).toList();
  }

  @override
  Future<List<ProductEntity>> getFeaturedProducts() async => products;

  @override
  Future<List<ProductEntity>> getNewProducts() async => products;

  @override
  Future<List<ProductEntity>> getBestSellerProducts() async => products;

  @override
  Future<ProductEntity> getProductById(String id) async => products.first;

  @override
  Future<List<ProductEntity>> searchProducts(String query, {String? startAfterId, int limit = 11}) async {
    return products.take(limit).toList();
  }

  @override
  Future<List<ProductEntity>> getProductsByIds(List<String> ids) async {
    return products.where((p) => ids.contains(p.id)).toList();
  }
}

void main() {
  group('PaginatedProductsNotifier', () {
    test('initial state is loading', () async {
      final repo = MockProductsRepo([]);
      final notifier = PaginatedProductsNotifier(repo);
      expect(notifier.state.isLoading, true);
      await Future.delayed(const Duration(milliseconds: 50));
      notifier.dispose();
    });

    test('fetchNextPage loads products', () async {
      final products = List.generate(15, (i) => ProductEntity(
        id: 'p$i',
        nameAr: 'منتج $i',
        nameEn: 'Product $i',
        descriptionAr: '',
        descriptionEn: '',
        categoryId: 'c1',
        price: 100.0 * (i + 1),
        images: [],
      ));
      final repo = MockProductsRepo(products);
      final notifier = PaginatedProductsNotifier(repo);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state.items.length, 10);
      expect(notifier.state.hasMore, true);
      expect(notifier.state.isLoading, false);
      notifier.dispose();
    });

    test('refresh resets products', () async {
      final products = List.generate(5, (i) => ProductEntity(
        id: 'p$i',
        nameAr: 'منتج $i',
        nameEn: 'Product $i',
        descriptionAr: '',
        descriptionEn: '',
        categoryId: 'c1',
        price: 100.0,
        images: [],
      ));
      final repo = MockProductsRepo(products);
      final notifier = PaginatedProductsNotifier(repo);

      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.state.items.length, 5);

      await notifier.refresh();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.state.items.length, 5);
      notifier.dispose();
    });
  });

  group('PaginatedProductsState', () {
    test('copyWith works correctly', () {
      final state = const PaginatedProductsState();
      final copy = state.copyWith(items: [testProduct], isLoading: false);
      expect(copy.items.length, 1);
      expect(copy.isLoading, false);
    });
  });
}

final testProduct = ProductEntity(
  id: 'p1',
  nameAr: 'منتج',
  nameEn: 'Product',
  descriptionAr: '',
  descriptionEn: '',
  categoryId: 'c1',
  price: 100.0,
  images: [],
);
