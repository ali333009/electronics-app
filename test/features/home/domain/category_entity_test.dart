import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/home/domain/entities/category_entity.dart';

void main() {
  group('CategoryEntity', () {
    test('creates with default values', () {
      final cat = CategoryEntity(id: 'c1', nameAr: 'قسم', nameEn: 'Category');
      expect(cat.order, 0);
      expect(cat.imageUrl, null);
    });
  });
}
