import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/home/data/models/category_model.dart';
import 'package:elct/features/home/domain/entities/category_entity.dart';

Map<String, dynamic> fullCategoryData() => {
  'id': 'cat-1',
  'nameAr': 'إلكترونيات',
  'nameEn': 'Electronics',
  'imageUrl': 'img.jpg',
  'order': 1,
  'isActive': true,
};

void main() {
  group('CategoryModel fromFirestore', () {
    test('parses full data correctly', () {
      final model = CategoryModel.fromFirestore(fullCategoryData());
      expect(model.id, 'cat-1');
      expect(model.isActive, true);
    });

    test('handles missing fields with defaults', () {
      final model = CategoryModel.fromFirestore({});
      expect(model.id, '');
      expect(model.isActive, true);
      expect(model.order, 0);
    });
  });

  group('CategoryModel toEntity', () {
    test('converts to CategoryEntity', () {
      final model = CategoryModel.fromFirestore(fullCategoryData());
      final entity = model.toEntity();
      expect(entity, isA<CategoryEntity>());
      expect(entity.id, 'cat-1');
    });
  });
}
