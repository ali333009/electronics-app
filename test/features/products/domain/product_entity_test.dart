import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/products/domain/entities/product_entity.dart';

void main() {
  group('ProductEntity', () {
    test('creates with required fields', () {
      final product = ProductEntity(
        id: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        descriptionAr: 'وصف',
        descriptionEn: 'Description',
        categoryId: 'c1',
        price: 100.0,
        images: ['img.jpg'],
      );
      expect(product.id, 'p1');
      expect(product.price, 100.0);
      expect(product.rating, 0);
      expect(product.reviewCount, 0);
      expect(product.isExclusive, false);
    });

    test('uses default values correctly', () {
      final product = ProductEntity(
        id: 'p1',
        nameAr: '',
        nameEn: '',
        descriptionAr: '',
        descriptionEn: '',
        categoryId: '',
        price: 0,
        images: [],
      );
      expect(product.specs, {});
      expect(product.tags, []);
      expect(product.stockQuantity, 0);
    });
  });
}
