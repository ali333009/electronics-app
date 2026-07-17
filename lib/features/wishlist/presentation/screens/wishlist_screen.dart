import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/models/product_card_data.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../domain/extensions/wishlist_item_entity_localization.dart';
import 'package:elct/features/cart/utils/add_to_cart_action.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/login_required_bottom_sheet.dart';
import '../providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppLocalizations.of(context)!.wishlistTitle,
          style: AppTypography.headlineMedium.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 0.5),
        ),
      ),
      body: wishlistAsync.when(
        loading: () => const _WishlistShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.loadErrorPrefix(e.toString()),
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: AppLocalizations.of(context)!.retry,
                onPressed: () => ref.invalidate(wishlistItemsProvider),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) return _buildEmptyState(context);
          final currency = ref.watch(currencyProvider);
          return RefreshIndicator(
            onRefresh: () => ref.refresh(wishlistItemsProvider.future),
            color: AppColors.gold,
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ProductCard(
                  product: ProductCardData(
                    id: item.productId, name: item.displayName(context),
                    price: item.price, originalPrice: item.originalPrice,
                    discountPercent: item.discountPercent,
                    images: [item.image], rating: item.rating,
                    reviewCount: item.reviewCount, stockQuantity: item.stockQuantity,
                  ),
                  currency: currency,
                  isInWishlist: true,
                  onWishlistTap: () async {
                    final uid = ref.read(currentUserIdProvider);
                    if (uid == null) { showLoginRequiredSheet(context, redirectPath: GoRouterState.of(context).uri.toString()); return; }
                    await ref.read(wishlistRepositoryProvider).toggleItem(
                      userId: uid, productId: item.productId,
                      nameAr: item.nameAr, nameEn: item.nameEn,
                      image: item.image, price: item.price,
                      originalPrice: item.originalPrice, discountPercent: item.discountPercent,
                      rating: item.rating, reviewCount: item.reviewCount,
                      stockQuantity: item.stockQuantity,
                    );
                  },
                  onAddToCart: () => addToCartAction(ref: ref, context: context,
                    productId: item.productId, nameAr: item.nameAr, nameEn: item.nameEn,
                    image: item.image, price: item.price,
                    originalPrice: item.originalPrice, discountPercent: item.discountPercent,
                    stockQuantity: item.stockQuantity),
                ).animate(delay: min(50 * index, 400).ms)
                    .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                    .slide(begin: const Offset(0, 0.1), duration: 300.ms, curve: Curves.easeOut);
              },
            ),
          ).animate().fadeIn(duration: 300.ms);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(AppLocalizations.of(context)!.wishlistEmpty, style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(AppLocalizations.of(context)!.wishlistEmptySubtitle, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: SizedBox(
              width: 200,
              child: AppButton(
                text: AppLocalizations.of(context)!.shopNow,
                onPressed: () => context.go(Routes.home),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistShimmer extends StatelessWidget {
  const _WishlistShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.55,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => const AppShimmer(height: double.infinity, borderRadius: 24),
    );
  }
}
