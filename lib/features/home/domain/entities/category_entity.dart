class CategoryEntity {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final String? iconName;
  final int order;

  const CategoryEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    this.iconName,
    this.order = 0,
  });
}
