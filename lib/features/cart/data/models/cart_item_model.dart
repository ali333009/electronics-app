import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel {
  final String id;
  final String userId;
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

  const CartItemModel({
    required this.id,
    required this.userId,
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

  factory CartItemModel.fromFirestore(Map<String, dynamic> data) {
    return CartItemModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      nameAr: data['nameAr'] ?? '',
      nameEn: data['nameEn'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      discountPercent: data['discountPercent'] as int?,
      quantity: data['quantity'] ?? 1,
      stockQuantity: data['stockQuantity'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      selectedOptions: _parseSelectedOptions(data),
    );
  }

  static Map<String, String>? _parseSelectedOptions(Map<String, dynamic> data) {
    if (data['selectedOptions'] is Map) {
      final map = data['selectedOptions'] as Map;
      return map.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    // Migration from old fields
    final result = <String, String>{};
    if (data['selectedColor'] != null) result['اللون'] = data['selectedColor'].toString();
    if (data['selectedSize'] != null) result['المقاس'] = data['selectedSize'].toString();
    
    return result.isEmpty ? null : result;
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
      'quantity': quantity,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
      'selectedOptions': selectedOptions,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      productId: productId,
      nameAr: nameAr,
      nameEn: nameEn,
      image: image,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      quantity: quantity,
      stockQuantity: stockQuantity,
      isAvailable: isAvailable,
      selectedOptions: selectedOptions,
    );
  }
}
