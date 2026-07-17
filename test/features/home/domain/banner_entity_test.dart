import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/home/domain/entities/banner_entity.dart';

void main() {
  group('BannerEntity', () {
    test('creates with default values', () {
      final banner = BannerEntity(
        id: 'b1',
        imageUrl: 'img.jpg',
        titleAr: 'عرض',
        titleEn: 'Offer',
      );
      expect(banner.targetType, 'category');
      expect(banner.order, 0);
      expect(banner.zone, 'header');
      expect(banner.targetId, null);
    });
  });
}
