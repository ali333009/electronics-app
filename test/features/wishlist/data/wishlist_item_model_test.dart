import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:elct/features/wishlist/domain/entities/wishlist_item_entity.dart';

Map<String, dynamic> fullWishlistData() => {
  'id': 'wish-1',
  'userId': 'user-1',
  'productId': 'prod-1',
  'nameAr': 'منتج',
  'nameEn': 'Product',
  'image': 'img.jpg',
  'price': 100.0,
  'originalPrice': 150.0,
  'discountPercent': 33,
  'rating': 4.5,
  'reviewCount': 10,
};

void main() {
  group('WishlistItemModel fromFirestore', () {
    test('parses full data correctly', () {
      final model = WishlistItemModel.fromFirestore(fullWishlistData());
      expect(model.id, 'wish-1');
      expect(model.price, 100.0);
      expect(model.rating, 4.5);
    });

    test('handles missing fields with defaults', () {
      final model = WishlistItemModel.fromFirestore({});
      expect(model.id, '');
      expect(model.price, 0.0);
      expect(model.rating, 0.0);
    });
  });

  group('WishlistItemModel toEntity', () {
    test('converts to entity correctly', () {
      final model = WishlistItemModel.fromFirestore(fullWishlistData());
      final entity = model.toEntity();
      expect(entity, isA<WishlistItemEntity>());
      expect(entity.productId, 'prod-1');
    });
  });
}
