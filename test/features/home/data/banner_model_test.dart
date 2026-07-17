import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/home/data/models/banner_model.dart';
import 'package:elct/features/home/domain/entities/banner_entity.dart';

Map<String, dynamic> fullBannerData() => {
  'id': 'banner-1',
  'imageUrl': 'img.jpg',
  'titleAr': 'عرض',
  'titleEn': 'Offer',
  'subtitleAr': 'خصم',
  'subtitleEn': 'Discount',
  'targetType': 'product',
  'targetId': 'prod-1',
  'order': 1,
  'isActive': true,
  'zone': 'header',
};

void main() {
  group('BannerModel fromFirestore', () {
    test('parses full data correctly', () {
      final model = BannerModel.fromFirestore(fullBannerData());
      expect(model.id, 'banner-1');
      expect(model.targetType, 'product');
      expect(model.isActive, true);
      expect(model.targetId, 'prod-1');
    });

    test('handles missing fields with defaults', () {
      final model = BannerModel.fromFirestore({});
      expect(model.id, '');
      expect(model.targetType, 'category');
      expect(model.isActive, true);
      expect(model.zone, 'header');
    });
  });

  group('BannerModel toEntity', () {
    test('converts to BannerEntity', () {
      final model = BannerModel.fromFirestore(fullBannerData());
      final entity = model.toEntity();
      expect(entity, isA<BannerEntity>());
      expect(entity.targetType, 'product');
    });
  });
}
