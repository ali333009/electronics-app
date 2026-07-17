import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/home/data/repositories/home_repository_impl.dart';
import 'package:elct/features/home/data/models/banner_model.dart';
import 'package:elct/features/home/data/models/category_model.dart';
import 'package:elct/features/products/domain/entities/product_entity.dart';
import '../../../helpers/mock_datasources.dart';

void main() {
  group('HomeRepositoryImpl', () {
    late MockHomeDatasource mockHome;
    late MockProductsRepository mockProductsRepo;
    late HomeRepositoryImpl repository;

    setUp(() {
      mockHome = MockHomeDatasource();
      mockProductsRepo = MockProductsRepository([]);
      repository = HomeRepositoryImpl(datasource: mockHome, productsRepo: mockProductsRepo);
    });

    test('getHomeData returns HomeDataEntity with all sections', () async {
      mockHome.banners = [BannerModel(id: 'b1', imageUrl: 'img.jpg', titleAr: 'عرض', titleEn: 'Offer')];
      mockHome.categories = [CategoryModel(id: 'c1', nameAr: 'قسم', nameEn: 'Cat')];
      mockProductsRepo.products = [
        ProductEntity(id: 'p1', nameAr: 'منتج', nameEn: 'P', descriptionAr: '', descriptionEn: '',
            categoryId: 'c1', price: 100, images: []),
      ];

      final data = await repository.getHomeData();
      expect(data.banners.length, 1);
      expect(data.categories.length, 1);
      expect(data.featuredProducts.length, 1);
    });

    test('getHomeData handles errors with empty lists', () async {
      mockHome.throwOnError = true;
      final data = await repository.getHomeData();
      expect(data.banners, []);
      expect(data.categories, []);
      expect(data.featuredProducts, []);
    });
  });
}
