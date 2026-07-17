import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:elct/features/wishlist/data/models/wishlist_item_model.dart';
import '../../../helpers/mock_datasources.dart';

void main() {
  group('WishlistRepositoryImpl', () {
    late MockWishlistDatasource mockDs;
    late WishlistRepositoryImpl repository;

    setUp(() {
      mockDs = MockWishlistDatasource();
      repository = WishlistRepositoryImpl(datasource: mockDs);
    });

    test('toggleItem adds item if not in wishlist', () async {
      await repository.toggleItem(
        userId: 'u1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
      );
      expect(mockDs.items.length, 1);
    });

    test('toggleItem removes item if already in wishlist', () async {
      mockDs.items = [
        WishlistItemModel(id: 'p1', userId: 'u1', productId: 'p1',
            nameAr: 'منتج', nameEn: 'P', image: 'img.jpg', price: 100),
      ];
      await repository.toggleItem(
        userId: 'u1',
        productId: 'p1',
        nameAr: 'منتج',
        nameEn: 'Product',
        image: 'img.jpg',
        price: 100.0,
      );
      expect(mockDs.items.length, 0);
    });

    test('isInWishlist returns correct status', () async {
      expect(await repository.isInWishlist('u1', 'p1'), false);
      mockDs.items = [
        WishlistItemModel(id: 'p1', userId: 'u1', productId: 'p1',
            nameAr: 'منتج', nameEn: 'P', image: 'img.jpg', price: 100),
      ];
      expect(await repository.isInWishlist('u1', 'p1'), true);
    });
  });
}
