class CartItemEntity {
  final String id;
  final String productId;
  final String nameAr;
  final String nameEn;
  final String image;
  final double price;
  final double? originalPrice;
  final int? discountPercent;
  final int quantity;
  final int stockQuantity;
  final bool isAvailable;
  final Map<String, String>? selectedOptions;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.nameAr,
    required this.nameEn,
    required this.image,
    required this.price,
    this.originalPrice,
    this.discountPercent,
    required this.quantity,
    this.stockQuantity = 0,
    this.isAvailable = true,
    this.selectedOptions,
  });

  double get totalPrice => price * quantity;
  double? get totalOriginalPrice =>
      originalPrice != null ? originalPrice! * quantity : null;
}
