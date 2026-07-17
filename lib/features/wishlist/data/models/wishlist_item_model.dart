import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/wishlist_item_entity.dart';

class WishlistItemModel {
  final String id;
  final String userId;
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

  const WishlistItemModel({
    required this.id,
    required this.userId,
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

  factory WishlistItemModel.fromFirestore(Map<String, dynamic> data) {
    return WishlistItemModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      nameAr: data['nameAr'] ?? '',
      nameEn: data['nameEn'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      discountPercent: data['discountPercent'] as int?,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      stockQuantity: (data['stockQuantity'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'image': image,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'rating': rating,
      'reviewCount': reviewCount,
      'stockQuantity': stockQuantity,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }

  WishlistItemEntity toEntity() {
    return WishlistItemEntity(
      id: id,
      productId: productId,
      nameAr: nameAr,
      nameEn: nameEn,
      image: image,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      rating: rating,
      reviewCount: reviewCount,
      stockQuantity: stockQuantity,
    );
  }
}
