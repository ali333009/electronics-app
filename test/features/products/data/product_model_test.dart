import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elct/features/products/data/models/product_model.dart';

Map<String, dynamic> fullProductData() => {
  'id': 'prod-1',
  'nameAr': 'منتج تجريبي',
  'nameEn': 'Test Product',
  'descriptionAr': 'وصف تجريبي',
  'descriptionEn': 'Test description',
  'categoryId': 'cat-1',
  'price': 100.0,
  'originalPrice': 150.0,
  'discountPercent': 33,
  'images': ['img1.jpg', 'img2.jpg'],
  'rating': 4.5,
  'reviewCount': 10,
  'stockQuantity': 50,
  'isFeatured': true,
  'isExclusive': true,
  'isBestSeller': true,
  'isNew': true,
  'specs': {'color': 'red', 'size': 'M'},
  'tags': ['electronics'],
  'searchKeywords': ['test', 'product'],
  'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
  'updatedAt': Timestamp.fromDate(DateTime(2025, 1, 2)),
};

void main() {
  group('ProductModel fromFirestore', () {
    test('parses full data correctly', () {
      final model = ProductModel.fromFirestore(fullProductData());
      expect(model.id, 'prod-1');
      expect(model.nameAr, 'منتج تجريبي');
      expect(model.price, 100.0);
      expect(model.originalPrice, 150.0);
      expect(model.discountPercent, 33);
      expect(model.images, ['img1.jpg', 'img2.jpg']);
      expect(model.isFeatured, true);
      expect(model.isExclusive, true);
      expect(model.isBestSeller, true);
      expect(model.isNew, true);
      expect(model.specs['color'], 'red');
      expect(model.tags, ['electronics']);
      expect(model.searchKeywords, ['test', 'product']);
      expect(model.createdAt, DateTime(2025, 1, 1));
    });

    test('handles missing fields with defaults', () {
      final model = ProductModel.fromFirestore({});
      expect(model.id, '');
      expect(model.price, 0.0);
      expect(model.rating, 0.0);
      expect(model.images, []);
      expect(model.isFeatured, false);
      expect(model.specs, {});
      expect(model.tags, []);
      expect(model.searchKeywords, []);
      expect(model.createdAt, null);
    });

    test('handles string boolean values', () {
      final data = fullProductData();
      data['isFeatured'] = 'true';
      data['isExclusive'] = 'true';
      data['isBestSeller'] = 'true';
      data['isNew'] = 'true';
      final model = ProductModel.fromFirestore(data);
      expect(model.isFeatured, true);
      expect(model.isExclusive, true);
      expect(model.isBestSeller, true);
      expect(model.isNew, true);
    });

    test('handles single image as string', () {
      final data = fullProductData();
      data['images'] = 'single.jpg';
      final model = ProductModel.fromFirestore(data);
      expect(model.images, ['single.jpg']);
    });
  });

  group('ProductModel toFirestore', () {
    test('serializes all fields correctly', () {
      final model = ProductModel.fromFirestore(fullProductData());
      final data = model.toFirestore();
      expect(data['id'], 'prod-1');
      expect(data['price'], 100.0);
      expect(data['images'], ['img1.jpg', 'img2.jpg']);
      expect(data['createdAt'], DateTime(2025, 1, 1));
    });
  });
}
