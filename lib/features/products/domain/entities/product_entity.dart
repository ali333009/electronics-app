class OptionItem {
  final String name;
  final String? hex;
  const OptionItem({required this.name, this.hex});
}

class ProductEntity {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String categoryId;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final int stockQuantity;
  final bool isExclusive;
  final bool isBestSeller;
  final bool isNew;
  final Map<String, String> specs;
  final List<String> tags;
  final Map<String, List<OptionItem>> options;

  const ProductEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.categoryId,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.images,
    this.rating = 0,
    this.reviewCount = 0,
    this.stockQuantity = 0,
    this.isExclusive = false,
    this.isBestSeller = false,
    this.isNew = false,
    this.specs = const {},
    this.tags = const [],
    this.options = const {},
  });
}
