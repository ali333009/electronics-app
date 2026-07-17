import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/home/domain/entities/home_data_entity.dart';

void main() {
  group('HomeDataEntity', () {
    test('creates with required fields', () {
      final homeData = HomeDataEntity(
        banners: [],
        categories: [],
        featuredProducts: [],
        newProducts: [],
        bestSellers: [],
      );
      expect(homeData.middleBanners, []);
      expect(homeData.bottomBanner, null);
    });
  });
}
