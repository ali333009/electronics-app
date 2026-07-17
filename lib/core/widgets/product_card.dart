// TODO: This widget is used in 5+ screens and should be kept focused. 
// Any new product-card variant should be a separate widget or composable.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/core/theme/app_colors.dart';
import 'package:elct/core/theme/app_typography.dart';
import 'package:elct/core/router/routes.dart';
import 'package:elct/core/models/product_card_data.dart';
import 'package:elct/core/models/currency.dart';
import 'package:elct/core/utils/price_formatter.dart';
import 'app_shimmer.dart';

class ProductCard extends StatefulWidget {
  final ProductCardData product;
  final double? width;
  final bool isInWishlist;
  final Currency currency;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.currency,
    this.width,
    this.isInWishlist = false,
    this.onWishlistTap,
    this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _animateHeart() {
    _heartController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.product.stockQuantity == 0;
    final hasDiscount = widget.product.originalPrice != null &&
        widget.product.originalPrice! > widget.product.price;

    return GestureDetector(
      onTap: () => context.push('${Routes.products}/${widget.product.id}'),
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Image Area
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surfaceLight,
                          AppColors.border,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                    ),
                    child: widget.product.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                            child: Hero(
                              tag: 'product_${widget.product.id}',
                              child: CachedNetworkImage(
                                imageUrl: widget.product.images.first,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                // Limit in-memory decode size → faster scroll, less RAM
                                memCacheWidth: 400,
                                memCacheHeight: 400,
                                placeholder: (_, _) => const AppShimmer(
                                  height: double.infinity,
                                  borderRadius: 22,
                                ),
                                errorWidget: (_, _, _) => const Center(
                                  child: Icon(Icons.checkroom_outlined, size: 48, color: AppColors.textMuted),
                                ),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.checkroom_outlined, size: 48, color: AppColors.textMuted),
                          ),
                  ),
                   // Top Left Wishlist/Favorite Icon
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    top: 12,
                    start: 12,
                    child: GestureDetector(
                      onTap: () {
                        _animateHeart();
                        widget.onWishlistTap?.call();
                      },
                      child: AnimatedBuilder(
                          animation: _heartController,
                          builder: (context, child) {
                            final press = _heartController.value < 0.5
                                ? 1.0 - (_heartController.value * 0.6)
                                : 0.7 + ((_heartController.value - 0.5) * 0.6);
                            return Transform.scale(
                              scale: press,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                widget.isInWishlist ? Icons.favorite : Icons.favorite_border,
                                color: widget.isInWishlist ? AppColors.error : AppColors.textPrimary,
                                size: 18,
                              ),
                            ),
                        ),
                      ),
                    ),
                  ),
                  // Top Right Badges (Discount, Out of Stock)
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    top: 12,
                    end: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.product.stockQuantity == 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: _buildBadge(AppLocalizations.of(context)!.outOfStock, AppColors.error.withValues(alpha: 0.9)),
                          ),
                        if (widget.product.discountPercent != null && widget.product.discountPercent! > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: _buildBadge(AppLocalizations.of(context)!.discountPercent(widget.product.discountPercent!), Colors.red),
                          ),
                      ],
                    ),
                  ),
                  // Bottom Right Badges (Best Seller, New, Exclusive)
                  if (widget.product.isBestSeller || widget.product.isNew || widget.product.isExclusive)
                    Positioned.directional(
                      textDirection: Directionality.of(context),
                      bottom: 8,
                      end: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.product.isExclusive)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 4),
                              child: _buildBadge(AppLocalizations.of(context)!.exclusive, AppColors.badgeExclusive),
                            ),
                          if (widget.product.isNew)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(start: 4),
                              child: _buildBadge(AppLocalizations.of(context)!.newLabel, AppColors.badgeNew),
                            ),
                          if (widget.product.isBestSeller)
                            _buildBadge(AppLocalizations.of(context)!.bestSeller, AppColors.goldLight, icon: Icons.star),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Bottom Info Area
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price and Rating Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatPrice(widget.product.price, widget.currency),
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(height: 1),
                              Text(
                                formatPrice(widget.product.originalPrice!, widget.currency),
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.error,
                                  decorationThickness: 1.6,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Rating
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.product.reviewCount == 0 ? "0.0" : widget.product.rating.toStringAsFixed(1),
                                style: AppTypography.badge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Add to Cart Button
                  GestureDetector(
                    onTap: isOutOfStock ? null : widget.onAddToCart,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isOutOfStock ? AppColors.textMuted : Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isOutOfStock) ...[
                              const Icon(
                                Icons.shopping_cart_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                isOutOfStock ? AppLocalizations.of(context)!.outOfStock : AppLocalizations.of(context)!.addToCart,
                                style: AppTypography.captionBold.copyWith(
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {IconData? icon}) {
    final hasIcon = icon != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: hasIcon
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  icon,
                  size: 12,
                  color: Colors.black,
                ),
              ],
            )
          : Text(
              text,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}
