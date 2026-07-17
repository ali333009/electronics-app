class WishlistItemEntity {
  final String id;
  final String productId;
  final String nameAr;
  final String nameEn;
  final String image;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final double rating;
  final int reviewCount;
  final int stockQuantity;

  const WishlistItemEntity({
    required this.id,
    required this.productId,
    required this.nameAr,
    required this.nameEn,
    required this.image,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    this.rating = 0,
    this.reviewCount = 0,
    this.stockQuantity = 0,
  });
}
