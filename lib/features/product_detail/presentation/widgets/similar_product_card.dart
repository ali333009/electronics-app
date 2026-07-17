import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../products/domain/extensions/product_entity_localization.dart';

class SimilarProductCard extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  const SimilarProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.05),
                      Colors.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: product.images.isNotEmpty
                    ? Hero(tag: 'product_${product.id}', child: CachedNetworkImage(
                        imageUrl: product.images.first,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120,
                        memCacheWidth: 300,
                        memCacheHeight: 240,
                        placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold)),
                        errorWidget: (_, _, _) => const Icon(Icons.image_outlined, color: AppColors.textMuted)))
                    : const Center(child: Icon(Icons.image_outlined, color: AppColors.textMuted)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.displayName(context), style: AppTypography.captionBold.copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(product.reviewCount == 0 ? "0.0" : product.rating.toStringAsFixed(1), style: AppTypography.badge.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(product.price.formatPrice(currency), style: AppTypography.bodyLargeBold.copyWith(color: AppColors.gold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
