import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel {
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
  final bool isFeatured;
  final bool isExclusive;
  final bool isBestSeller;
  final bool isNew;
  final Map<String, String> specs;
  final List<String> tags;
  final List<String> searchKeywords;
  final Map<String, List<OptionItem>> options;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
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
    this.isFeatured = false,
    this.isExclusive = false,
    this.isBestSeller = false,
    this.isNew = false,
    this.specs = const {},
    this.tags = const [],
    this.searchKeywords = const [],
    this.options = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromFirestore(Map<String, dynamic> data, {String? id}) {
    return ProductModel(
      id: (data['id'] ?? id ?? '').toString(),
      nameAr: (data['nameAr'] ?? '').toString(),
      nameEn: (data['nameEn'] ?? '').toString(),
      descriptionAr: (data['descriptionAr'] ?? '').toString(),
      descriptionEn: (data['descriptionEn'] ?? '').toString(),
      categoryId: (data['categoryId'] ?? '').toString(),
      price: (data['price'] as num? ?? 0).toDouble(),
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      discountPercent: (data['discountPercent'] as num?)?.toInt(),
      images: data['images'] is List
          ? (data['images'] as List).map((e) => e.toString()).toList()
          : (data['images'] != null ? [data['images'].toString()] : []),
      rating: double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(data['reviewCount']?.toString() ?? '0') ?? 0,
      stockQuantity: int.tryParse(data['stockQuantity']?.toString() ?? '0') ?? 0,
      isFeatured: data['isFeatured'] == true || data['isFeatured'] == 'true',
      isExclusive: data['isExclusive'] == true || data['isExclusive'] == 'true',
      isBestSeller: data['isBestSeller'] == true || data['isBestSeller'] == 'true',
      isNew: data['isNew'] == true || data['isNew'] == 'true',
      specs: (data['specs'] is Map)
          ? (data['specs'] as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
          : {},
      tags: data['tags'] is List
          ? (data['tags'] as List).map((e) => e.toString()).toList()
          : (data['tags'] != null ? [data['tags'].toString()] : []),
      searchKeywords: data['searchKeywords'] is List
          ? (data['searchKeywords'] as List).map((e) => e.toString()).toList()
          : [],
      options: _parseOptions(data),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'descriptionAr': descriptionAr,
      'descriptionEn': descriptionEn,
      'categoryId': categoryId,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercent': discountPercent,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'stockQuantity': stockQuantity,
      'isFeatured': isFeatured,
      'isExclusive': isExclusive,
      'isBestSeller': isBestSeller,
      'isNew': isNew,
      'specs': specs,
      'tags': tags,
      'searchKeywords': searchKeywords,
      'options': options.map((k, v) => MapEntry(k, v.map((o) => {'name': o.name, if (o.hex != null) 'hex': o.hex}).toList())),
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      nameAr: nameAr,
      nameEn: nameEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      categoryId: categoryId,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      images: images,
      rating: rating,
      reviewCount: reviewCount,
      stockQuantity: stockQuantity,
      isExclusive: isExclusive,
      isBestSeller: isBestSeller,
      isNew: isNew,
      specs: specs,
      tags: tags,
      options: options,
    );
  }
  static Map<String, List<OptionItem>> _parseOptions(Map<String, dynamic> data) {
    final result = <String, List<OptionItem>>{};
    
    if (data['options'] is Map) {
      final map = data['options'] as Map;
      for (final key in map.keys) {
        final val = map[key];
        if (val is List) {
          result[key.toString()] = val.map((e) {
            if (e is Map) {
              return OptionItem(
                name: (e['name'] ?? '').toString(),
                hex: e['hex']?.toString(),
              );
            }
            return OptionItem(name: e.toString());
          }).toList();
        }
      }
    }
    
    if (data['colors'] is List && (data['colors'] as List).isNotEmpty && !result.containsKey('اللون')) {
      result['اللون'] = (data['colors'] as List).map((e) => OptionItem(name: e.toString())).toList();
    }
    if (data['sizes'] is List && (data['sizes'] as List).isNotEmpty && !result.containsKey('المقاس')) {
      result['المقاس'] = (data['sizes'] as List).map((e) => OptionItem(name: e.toString())).toList();
    }
    
    return result;
  }
}
