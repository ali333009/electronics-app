import '../../domain/entities/banner_entity.dart';

class BannerModel {
  final String id;
  final String imageUrl;
  final String titleAr;
  final String titleEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final String targetType;
  final String? targetId;
  final int order;
  final bool isActive;
  final String zone;
  final List<String>? productIds;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.targetType = 'category',
    this.targetId,
    this.order = 0,
    this.isActive = true,
    this.zone = 'header',
    this.productIds,
  });

  BannerEntity toEntity() => BannerEntity(
    id: id,
    imageUrl: imageUrl,
    titleAr: titleAr,
    titleEn: titleEn,
    subtitleAr: subtitleAr,
    subtitleEn: subtitleEn,
    targetType: targetType,
    targetId: targetId,
    order: order,
    zone: zone,
    productIds: productIds,
  );

  factory BannerModel.fromFirestore(Map<String, dynamic> data) {
    return BannerModel(
      id: (data['id'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      titleAr: (data['titleAr'] ?? '').toString(),
      titleEn: (data['titleEn'] ?? '').toString(),
      subtitleAr: data['subtitleAr']?.toString(),
      subtitleEn: data['subtitleEn']?.toString(),
      targetType: (data['targetType'] ?? 'category').toString(),
      targetId: data['targetId']?.toString(),
      order: (data['order'] as num? ?? 0).toInt(),
      isActive: data['isActive'] == null || data['isActive'] == true || data['isActive'] == 'true',
      zone: (data['zone'] ?? 'header').toString(),
      productIds: (data['productIds'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'titleAr': titleAr,
      'titleEn': titleEn,
      'subtitleAr': subtitleAr,
      'subtitleEn': subtitleEn,
      'targetType': targetType,
      'targetId': targetId,
      'order': order,
      'isActive': isActive,
      'zone': zone,
      'productIds': productIds,
    };
  }
}
