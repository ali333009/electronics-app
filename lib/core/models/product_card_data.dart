class ProductCardData {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final int stockQuantity;
  final bool isBestSeller;
  final bool isNew;
  final bool isExclusive;

  const ProductCardData({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.images = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.stockQuantity = 0,
    this.isBestSeller = false,
    this.isNew = false,
    this.isExclusive = false,
  });
}
