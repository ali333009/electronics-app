import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_products_grid_shimmer.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/models/product_card_data.dart';
import '../../../../core/providers/currency_provider.dart';
import 'package:elct/features/cart/utils/add_to_cart_action.dart';
import 'package:elct/features/wishlist/utils/toggle_wishlist_action.dart';
import '../../../products/domain/extensions/product_entity_localization.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/login_required_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasTyped = _searchQuery.isNotEmpty;

    // Use firebaseSearchProvider if user typed, otherwise use featuredProductsProvider
    final asyncProducts = hasTyped 
        ? ref.watch(firebaseSearchProvider(_searchQuery))
        : ref.watch(featuredProductsProvider);

    final results = asyncProducts.valueOrNull ?? [];
    final isLoading = asyncProducts.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                textDirection: Directionality.of(context),
                style: AppTypography.bodyLarge,
                textInputAction: TextInputAction.search,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  suffixIcon: hasTyped
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textMuted),
                          onPressed: () => context.pop(),
                        ),
                ),
              ),
            ),

            // ── Header/Counter ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  children: [
                    if (!hasTyped) ...[
                      const Icon(Icons.local_fire_department_rounded, color: AppColors.gold, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.popularProductsTitle,
                        style: AppTypography.titleLarge.copyWith(color: AppColors.gold),
                      ),
                    ] else if (results.isNotEmpty && !isLoading) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${results.length} ${l10n.itemsCount(results.length).split(' ').last}',
                          style: AppTypography.captionBold.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Body ────────────────────────────────────────────────
            Expanded(child: _buildBody(l10n, isLoading, hasTyped, results)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    AppLocalizations l10n,
    bool isLoading,
    bool hasTyped,
    List<ProductEntity> results,
  ) {
    if (isLoading) return _buildLoading();

    if (results.isEmpty && hasTyped) return _buildEmptyResults(l10n);

    return _buildResults(results);
  }

  Widget _buildEmptyResults(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: AppColors.textMuted.withValues(alpha: 0.3)),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.searchEmptyTitle, style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '"$_searchQuery"',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const AppProductsGridShimmer();
  }

  Widget _buildResults(List<ProductEntity> results) {
    final currency = ref.watch(currencyProvider);
    final wishlistItems = ref.watch(wishlistItemsProvider).valueOrNull ?? [];
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final p = results[i];
        return ProductCard(
          product: ProductCardData(
            id: p.id, name: p.displayName(context), price: p.price,
            originalPrice: p.originalPrice, discountPercent: p.discountPercent,
            images: p.images, rating: p.rating, reviewCount: p.reviewCount,
            stockQuantity: p.stockQuantity, isBestSeller: p.isBestSeller,
            isNew: p.isNew, isExclusive: p.isExclusive,
          ),
          currency: currency,
          isInWishlist: wishlistItems.any((item) => item.productId == p.id),
          onWishlistTap: () {
            final uid = ref.read(currentUserIdProvider);
            if (uid == null) { showLoginRequiredSheet(context, redirectPath: GoRouterState.of(context).uri.toString()); return; }
            toggleWishlistAction(ref: ref, context: context, userId: uid,
              productId: p.id, nameAr: p.nameAr, nameEn: p.nameEn,
              image: p.images.isNotEmpty ? p.images.first : '',
              price: p.price, originalPrice: p.originalPrice,
              discountPercent: p.discountPercent, rating: p.rating,
              reviewCount: p.reviewCount, stockQuantity: p.stockQuantity,
              isInWishlist: wishlistItems.any((item) => item.productId == p.id));
          },
          onAddToCart: () => addToCartAction(ref: ref, context: context,
            productId: p.id, nameAr: p.nameAr, nameEn: p.nameEn,
            image: p.images.isNotEmpty ? p.images.first : '',
            price: p.price, originalPrice: p.originalPrice,
            discountPercent: p.discountPercent, stockQuantity: p.stockQuantity),
        );
      },
    );
  }
}

