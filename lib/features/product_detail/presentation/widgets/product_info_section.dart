import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../products/domain/extensions/product_entity_localization.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'star_rating.dart';

class ProductInfoSection extends ConsumerWidget {
  final ProductEntity product;
  const ProductInfoSection({super.key, required this.product});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyProvider);
    final origPrice = product.originalPrice;
    final discPct = product.discountPercent;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(product.displayName(context), style: AppTypography.displayMedium.copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          Row(
            children: [
              StarRating(rating: product.reviewCount == 0 ? 0.0 : product.rating, size: 18),
              const SizedBox(width: 8),
              Text(product.reviewCount == 0 ? "0.0" : product.rating.toStringAsFixed(1), style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Text(AppLocalizations.of(context)!.reviewCount(product.reviewCount), style: AppTypography.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(product.price.formatPrice(currency), style: AppTypography.price.copyWith(fontSize: 24, fontWeight: FontWeight.w900)),
              if (origPrice != null) ...[
                const SizedBox(width: 10),
                Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(origPrice.formatPrice(currency), style: AppTypography.priceMuted.copyWith(fontSize: 16))),
              ],
              if (discPct != null && discPct > 0) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.badgeDiscount, borderRadius: BorderRadius.circular(6)),
                  child: Text(AppLocalizations.of(context)!.discountPercent(discPct), style: AppTypography.badge.copyWith(fontSize: 11, color: AppColors.white)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
