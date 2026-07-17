import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_products_grid_shimmer.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/models/product_card_data.dart';
import '../../../../core/providers/currency_provider.dart';
import 'package:elct/features/cart/utils/add_to_cart_action.dart';
import 'package:elct/features/wishlist/utils/toggle_wishlist_action.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/domain/entities/banner_entity.dart';
import '../../../products/domain/extensions/product_entity_localization.dart';
import '../../../home/domain/extensions/banner_entity_localization.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/login_required_bottom_sheet.dart';

final _bannerByIdProvider = FutureProvider.family<BannerEntity?, String>((ref, id) async {
  final repo = ref.read(homeRepositoryProvider);
  final model = await repo.getBannerById(id);
  return model?.toEntity();
});

final _campaignProductsProvider = FutureProvider.family<List<ProductEntity>, String>((ref, categoryId) async {
  return ref.read(productsRepositoryProvider).getProductsByCategory(categoryId);
});

final _campaignProductsByIdsProvider = FutureProvider.family<List<ProductEntity>, List<String>>((ref, ids) async {
  return ref.read(productsRepositoryProvider).getProductsByIds(ids);
});

class CampaignScreen extends ConsumerWidget {
  final String bannerId;

  const CampaignScreen({super.key, required this.bannerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerAsync = ref.watch(_bannerByIdProvider(bannerId));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: bannerAsync.when(
        loading: () => const _CampaignShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.loadError, style: AppTypography.bodyMedium),
              const SizedBox(height: 16),
              AppButton(text: l10n.retry, onPressed: () => ref.invalidate(_bannerByIdProvider(bannerId))),
            ],
          ),
        ),
        data: (banner) {
          if (banner == null) {
            return Center(child: Text(l10n.loadError, style: AppTypography.bodyMedium));
          }
          return _CampaignBody(banner: banner);
        },
      ),
    );
  }
}

class _CampaignShimmer extends StatelessWidget {
  const _CampaignShimmer();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: AppShimmer(height: 300)),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, _) => AppShimmer(height: double.infinity, borderRadius: 16),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }
}

class _CampaignBody extends ConsumerWidget {
  final BannerEntity banner;

  const _CampaignBody({required this.banner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final hasProducts = banner.productIds != null && banner.productIds!.isNotEmpty;
    final hasTarget = banner.targetId != null && banner.targetId!.isNotEmpty;

    Future<void> onRefresh() async {
      ref.invalidate(_bannerByIdProvider(banner.id));
      if (hasProducts) {
        ref.invalidate(_campaignProductsByIdsProvider(banner.productIds!));
      } else if (hasTarget) {
        ref.invalidate(_campaignProductsProvider(banner.targetId!));
      }
      // Wait a moment for UX
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!hasProducts && !hasTarget) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: AppColors.gold,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildBannerSection(banner, context)),
            SliverFillRemaining(
              child: Center(child: Text(l10n.noProducts, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary))),
            ),
          ],
        ),
      );
    }

    final productsAsync = hasProducts
        ? ref.watch(_campaignProductsByIdsProvider(banner.productIds!))
        : ref.watch(_campaignProductsProvider(banner.targetId!));

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.gold,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildBannerSection(banner, context)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _buildSectionHeader(context),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          productsAsync.when(
            loading: () => const SliverFillRemaining(child: AppProductsGridShimmer()),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('${l10n.loadError}: $e')),
            ),
            data: (products) {
              if (products.isEmpty) {
                return SliverFillRemaining(
                  child: Center(child: Text(l10n.noProducts, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary))),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final p = products[i];
                      return ProductCard(
                        product: ProductCardData(
                          id: p.id, name: p.displayName(context), price: p.price,
                          originalPrice: p.originalPrice, discountPercent: p.discountPercent,
                          images: p.images, rating: p.rating, reviewCount: p.reviewCount,
                          stockQuantity: p.stockQuantity, isBestSeller: p.isBestSeller,
                          isNew: p.isNew, isExclusive: p.isExclusive,
                        ),
                        currency: ref.watch(currencyProvider),
                        isInWishlist: (ref.watch(wishlistItemsProvider).valueOrNull ?? []).any((wi) => wi.productId == p.id),
                        onWishlistTap: () {
                          final uid = ref.read(currentUserIdProvider);
                          if (uid == null) { showLoginRequiredSheet(context, redirectPath: GoRouterState.of(context).uri.toString()); return; }
                          toggleWishlistAction(ref: ref, context: context, userId: uid,
                            productId: p.id, nameAr: p.nameAr, nameEn: p.nameEn,
                            image: p.images.isNotEmpty ? p.images.first : '',
                            price: p.price, originalPrice: p.originalPrice,
                            discountPercent: p.discountPercent, rating: p.rating,
                            reviewCount: p.reviewCount, stockQuantity: p.stockQuantity,
                            isInWishlist: (ref.watch(wishlistItemsProvider).valueOrNull ?? []).any((wi) => wi.productId == p.id));
                        },
                        onAddToCart: () => addToCartAction(ref: ref, context: context,
                          productId: p.id, nameAr: p.nameAr, nameEn: p.nameEn,
                          image: p.images.isNotEmpty ? p.images.first : '',
                          price: p.price, originalPrice: p.originalPrice,
                          discountPercent: p.discountPercent, stockQuantity: p.stockQuantity),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          AppLocalizations.of(context)!.products,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerSection(BannerEntity banner, BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: banner.imageUrl,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            placeholder: (_, _) => AppShimmer(height: 300),
            errorWidget: (_, _, _) => Container(color: AppColors.surfaceLight, child: const Icon(Icons.image, color: AppColors.textMuted, size: 64)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.black.withValues(alpha: 0.8),
                  AppColors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            top: MediaQuery.of(context).padding.top + 8,
            start: 8,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            bottom: 28,
            start: 20,
            end: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(banner.displayTitle(context),
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 8),
                if (banner.displaySubtitle(context) != null) ...[
                  Text(banner.displaySubtitle(context)!,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textWhiteMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
