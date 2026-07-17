import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/wishlist/domain/entities/wishlist_item_entity.dart';

void main() {
  group('WishlistItemEntity', () {
    test('creates with required fields', () {
      final item = WishlistItemEntity(
        id: 'w1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
      );
      expect(item.id, 'w1');
      expect(item.rating, 0);
      expect(item.reviewCount, 0);
    });
  });
}
