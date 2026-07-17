import '../../../products/domain/entities/product_entity.dart';
import 'banner_entity.dart';
import 'category_entity.dart';

class HomeDataEntity {
  final List<BannerEntity> banners;
  final List<BannerEntity> middleBanners;
  final BannerEntity? bottomBanner;
  final List<CategoryEntity> categories;
  final List<ProductEntity> featuredProducts;
  final List<ProductEntity> newProducts;
  final List<ProductEntity> bestSellers;

  const HomeDataEntity({
    required this.banners,
    this.middleBanners = const [],
    this.bottomBanner,
    required this.categories,
    required this.featuredProducts,
    required this.newProducts,
    required this.bestSellers,
  });
}
