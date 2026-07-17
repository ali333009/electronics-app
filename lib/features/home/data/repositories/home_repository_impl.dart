import '../../../../core/utils/log.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/repositories/i_products_repository.dart';
import '../../domain/entities/home_data_entity.dart';
import '../datasources/home_datasource.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';

class HomeRepositoryImpl {
  final HomeDatasource _datasource;
  final IProductsRepository _productsRepo;

  HomeRepositoryImpl({HomeDatasource? datasource, required IProductsRepository productsRepo})
    : _datasource = datasource ?? HomeDatasource(),
      _productsRepo = productsRepo;

  Future<BannerModel?> getBannerById(String id) => _datasource.getBannerById(id);

  Future<List<CategoryModel>> getCategories() => _datasource.getCategories();

  Future<HomeDataEntity> getHomeData() async {
    final results = await Future.wait([
      _datasource.getBanners().catchError((e) { logDebug('[HomeRepo] getBanners error: $e'); return <BannerModel>[]; }),
      _datasource.getBanners(zone: 'middle').catchError((e) { logDebug('[HomeRepo] getMiddleBanners error: $e'); return <BannerModel>[]; }),
      _datasource.getBottomBanner().catchError((e) { logDebug('[HomeRepo] getBottomBanner error: $e'); return null; }),
      _datasource.getCategories().catchError((e) { logDebug('[HomeRepo] getCategories error: $e'); return <CategoryModel>[]; }),
      _productsRepo.getFeaturedProducts().catchError((e) { logDebug('[HomeRepo] getFeatured error: $e'); return <ProductEntity>[]; }),
      _productsRepo.getNewProducts().catchError((e) { logDebug('[HomeRepo] getNewProducts error: $e'); return <ProductEntity>[]; }),
      _productsRepo.getBestSellerProducts().catchError((e) { logDebug('[HomeRepo] getBestSellers error: $e'); return <ProductEntity>[]; }),
    ]);

    return HomeDataEntity(
      banners: (results[0] as List<BannerModel>).map((m) => m.toEntity()).toList(),
      middleBanners: (results[1] as List<BannerModel>).map((m) => m.toEntity()).toList(),
      bottomBanner: (results[2] as BannerModel?)?.toEntity(),
      categories: (results[3] as List<CategoryModel>).map((m) => m.toEntity()).toList(),
      featuredProducts: results[4] as List<ProductEntity>,
      newProducts: results[5] as List<ProductEntity>,
      bestSellers: results[6] as List<ProductEntity>,
    );
  }
}
