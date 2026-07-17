class BannerEntity {
  final String id;
  final String imageUrl;
  final String titleAr;
  final String titleEn;
  final String? subtitleAr;
  final String? subtitleEn;
  final String targetType;
  final String? targetId;
  final int order;
  final String zone;
  final List<String>? productIds;

  const BannerEntity({
    required this.id,
    required this.imageUrl,
    required this.titleAr,
    required this.titleEn,
    this.subtitleAr,
    this.subtitleEn,
    this.targetType = 'category',
    this.targetId,
    this.order = 0,
    this.zone = 'header',
    this.productIds,
  });
}
