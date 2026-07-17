import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/products/data/repositories/products_repository_impl.dart';
import 'package:elct/features/products/data/models/product_model.dart';
import '../../../helpers/mock_datasources.dart';

void main() {
  group('ProductsRepositoryImpl', () {
    late MockProductsDatasource mockDs;
    late ProductsRepositoryImpl repository;

    setUp(() {
      mockDs = MockProductsDatasource();
      repository = ProductsRepositoryImpl(datasource: mockDs);
    });

    test('getProducts returns list of ProductEntity', () async {
      mockDs.products = [
        ProductModel(id: 'p1', nameAr: 'منتج', nameEn: 'P', descriptionAr: '', descriptionEn: '',
            categoryId: 'c1', price: 100, images: []),
      ];
      final products = await repository.getProducts();
      expect(products.length, 1);
      expect(products.first.id, 'p1');
    });

    test('getProductById returns entity', () async {
      mockDs.products = [
        ProductModel(id: 'p1', nameAr: 'منتج', nameEn: 'P', descriptionAr: '', descriptionEn: '',
            categoryId: 'c1', price: 100, images: []),
      ];
      final product = await repository.getProductById('p1');
      expect(product.id, 'p1');
    });

    test('searchProducts returns results', () async {
      mockDs.products = [
        ProductModel(id: 'p1', nameAr: 'منتج', nameEn: 'Product', descriptionAr: '', descriptionEn: '',
            categoryId: 'c1', price: 100, images: []),
      ];
      final results = await repository.searchProducts('Product');
      expect(results.length, 1);
    });
  });
}
