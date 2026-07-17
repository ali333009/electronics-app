import '../../domain/entities/category_entity.dart';

class CategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final String? iconName;
  final int order;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    this.iconName,
    this.order = 0,
    this.isActive = true,
  });

  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    nameAr: nameAr,
    nameEn: nameEn,
    imageUrl: imageUrl,
    iconName: iconName,
    order: order,
  );

  factory CategoryModel.fromFirestore(Map<String, dynamic> data) {
    return CategoryModel(
      id: (data['id'] ?? '').toString(),
      nameAr: (data['nameAr'] ?? '').toString(),
      nameEn: (data['nameEn'] ?? '').toString(),
      imageUrl: data['imageUrl']?.toString(),
      iconName: data['iconName']?.toString(),
      order: (data['order'] as num? ?? 0).toInt(),
      isActive: data['isActive'] == null || data['isActive'] == true || data['isActive'] == 'true',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'imageUrl': imageUrl,
      'iconName': iconName,
      'order': order,
      'isActive': isActive,
    };
  }
}
