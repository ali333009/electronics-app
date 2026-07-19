import 'dart:math';
// TODO: Split into smaller files. _buildCategorySliver and _buildFilteredProductsSliver 
// have near-identical grid/ProductCard logic that could share a builder.
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/load_more_indicator.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/models/currency.dart';
import '../providers/home_provider.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/home_header_section.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/paginated_products_provider.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/extensions/category_entity_localization.dart';
import '../../../products/domain/extensions/product_entity_localization.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../../core/models/product_card_data.dart';
import 'package:elct/features/cart/utils/add_to_cart_action.dart';
import 'package:elct/features/wishlist/utils/toggle_wishlist_action.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/login_required_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;
  final ScrollController _scrollController = ScrollController();
  String _activeFilter = 'all';
  String? _subCategoryId;

  static const _filters = ['all', 'offers', 'rating', 'bestSeller'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current >= maxScroll - 300) {
      if (_selectedCategoryId != null) {
        ref.read(paginatedCategoryProductsProvider(_selectedCategoryId!).notifier).fetchNextPage();
      } else {
        final params = FilterParams(filterType: _activeFilter, categoryId: _subCategoryId);
        ref.read(paginatedFilteredProductsProvider(params).notifier).fetchNextPage();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setFilter(String filter) {
    if (_activeFilter == filter) return;
    setState(() {
      _activeFilter = filter;
      _subCategoryId = null;
    });
  }

  void _showCurrencyPicker(BuildContext context) {
    final settings = ref.read(appSettingsProvider).valueOrNull;
    final enabledCodes = settings?.enabledCurrencies ?? [];
    final currencies = enabledCodes.isEmpty
        ? Currency.available
        : Currency.available.where((c) => enabledCodes.contains(c.code)).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.selectCurrency, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Divider(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: currencies.map((c) {
                    final isSelected = c.code == ref.read(currencyProvider).code;
                    return ListTile(
                      leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                      title: Text(c.name, style: AppTypography.bodyMedium.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      trailing: isSelected ? const Icon(Icons.check, color: AppColors.gold) : Text(c.symbol, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      onTap: () {
                        ref.read(currencyProvider.notifier).setCurrency(c);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.selectLanguage, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                leading: const Text('🇰🇼', style: TextStyle(fontSize: 24)),
                title: Text(AppLocalizations.of(context)!.arabic, style: AppTypography.bodyMedium.copyWith(fontWeight: ref.read(localeProvider).languageCode == 'ar' ? FontWeight.bold : FontWeight.normal)),
                trailing: ref.read(localeProvider).languageCode == 'ar' ? const Icon(Icons.check, color: AppColors.gold) : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale('ar');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                title: Text('English', style: AppTypography.bodyMedium.copyWith(fontWeight: ref.read(localeProvider).languageCode == 'en' ? FontWeight.bold : FontWeight.normal)),
                trailing: ref.read(localeProvider).languageCode == 'en' ? const Icon(Icons.check, color: AppColors.gold) : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale('en');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);
    return homeDataAsync.when(
      loading: () => _HomeShimmer(onRefresh: () => ref.refresh(homeDataProvider.future)),
      error: (e, _) => _buildError(e, ref),
      data: (data) => RefreshIndicator(
        onRefresh: () {
          ref.invalidate(homeDataProvider);
          final params = FilterParams(filterType: _activeFilter, categoryId: _subCategoryId);
          ref.invalidate(paginatedFilteredProductsProvider(params));
          return ref.refresh(homeDataProvider.future);
        },
        color: AppColors.gold,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: HomeHeaderSection(banners: data.banners, onCurrencyTap: () => _showCurrencyPicker(context), onLanguageTap: () => _showLanguagePicker(context))),
            SliverToBoxAdapter(
              child: _buildSectionHeader(AppLocalizations.of(context)!.sectionByCategory, null),
            ),
            SliverToBoxAdapter(child: _buildCategories(data.categories)),
            if (_selectedCategoryId != null) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  data.categories.where((c) => c.id == _selectedCategoryId).firstOrNull?.displayName(context) ?? '', 
                  null
                ),
              ),
              _buildCategorySliver(data.categories),
            ] else ...[
              if (data.newProducts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(AppLocalizations.of(context)!.sectionNewArrivals, () => context.go(Routes.categories)),
                ),
                SliverToBoxAdapter(child: _buildProductsRow(context, data.newProducts, data.categories)),
              ],
              if (data.bestSellers.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(AppLocalizations.of(context)!.sectionBestSellers, () => context.go(Routes.categories)),
                ),
                SliverToBoxAdapter(child: _buildProductsRow(context, data.bestSellers, data.categories)),
              ],
              // Banner Carousel in the middle
              if (data.middleBanners.isNotEmpty) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BannerCarousel(banners: data.middleBanners, height: 150),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
              if (data.featuredProducts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _buildSectionHeader(AppLocalizations.of(context)!.sectionExclusive, () => context.go(Routes.categories)),
                ),
                SliverToBoxAdapter(
                  child: _buildProductsRow(context, data.featuredProducts, data.categories),
                ),
              ],
              // Single Ad Banner
              if (data.bottomBanner != null) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BannerCarousel(banners: [data.bottomBanner!], height: 150),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
              // Filter Bar
              SliverToBoxAdapter(
                child: _buildFilterBar(data.categories),
              ),
              // Sub-category bar (only for Offers)
              if (_activeFilter == 'offers')
                SliverToBoxAdapter(
                  child: _buildSubCategoryBar(data.categories),
                ),
              // Filtered products grid
              _buildFilteredProductsSliver(data.categories),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(List<CategoryEntity> categories) {
    final t = AppLocalizations.of(context)!;
    final labels = {
      'all': t.all,
      'offers': t.offers,
      'rating': t.fiveStarRating,
      'bestSeller': t.bestSeller,
    };
    final icons = {
      'all': Icons.apps_rounded,
      'offers': Icons.local_fire_department_rounded,
      'rating': Icons.star_rounded,
      'bestSeller': Icons.trending_up_rounded,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.allProducts, style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final isActive = _activeFilter == f;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    child: Material(
                      color: isActive ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      elevation: isActive ? 4 : 0,
                      shadowColor: AppColors.gold.withValues(alpha: 0.3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () => _setFilter(f),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: isActive ? AppColors.gold : const Color(0xFFE0D9D0),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icons[f],
                                size: 16,
                                color: isActive ? AppColors.gold : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                labels[f]!,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                  color: isActive ? AppColors.gold : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryBar(List<CategoryEntity> categories) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // "All" sub-category chip
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _SubCategoryChip(
                label: AppLocalizations.of(context)!.all,
                isSelected: _subCategoryId == null,
                onTap: () => setState(() => _subCategoryId = null),
              ),
            ),
            ...categories.map((cat) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: _SubCategoryChip(
                label: cat.displayName(context),
                isSelected: _subCategoryId == cat.id,
                onTap: () => setState(() => _subCategoryId = cat.id),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid({EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16)}) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => AppShimmer(height: 260, borderRadius: 20),
          childCount: 4,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyState(IconData icon, String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 56, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(message, style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySliver(List<CategoryEntity> categories) {
    final state = ref.watch(paginatedCategoryProductsProvider(_selectedCategoryId!));
    final currency = ref.watch(currencyProvider);
    final wishlistItems = ref.watch(wishlistItemsProvider).valueOrNull ?? [];

    if (state.isLoading) return _buildShimmerGrid();

    if (state.items.isEmpty) return _buildEmptyState(Icons.category_outlined, AppLocalizations.of(context)!.noProducts);

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final p = state.items[i];
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
              childCount: state.items.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: LoadMoreIndicator(
            isLoadingMore: state.isLoadingMore,
            hasMore: state.hasMore,
          ),
        ),
      ],
    );
  }

  Widget _buildFilteredProductsSliver(List<CategoryEntity> categories) {
    final params = FilterParams(filterType: _activeFilter, categoryId: _subCategoryId);
    final state = ref.watch(paginatedFilteredProductsProvider(params));
    final currency = ref.watch(currencyProvider);
    final wishlistItems = ref.watch(wishlistItemsProvider).valueOrNull ?? [];

    if (state.isLoading) return _buildShimmerGrid(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0));

    if (state.items.isEmpty) return _buildEmptyState(Icons.search_off_rounded, AppLocalizations.of(context)!.noProductsInSection);

    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final p = state.items[i];
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
              childCount: state.items.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: LoadMoreIndicator(
            isLoadingMore: state.isLoadingMore,
            hasMore: state.hasMore,
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object e, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(AppLocalizations.of(context)!.loadError, style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            AppButton(text: AppLocalizations.of(context)!.retry, onPressed: () => ref.refresh(homeDataProvider.future)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onMore) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Text(title, style: AppTypography.titleLarge),
          if (onMore != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: onMore,
              child: Text(AppLocalizations.of(context)!.viewAll, style: AppTypography.bodyMedium.copyWith(color: AppColors.gold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategories(List<CategoryEntity> categories) {
    if (categories.isEmpty) return const SizedBox();
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            final isSel = _selectedCategoryId == null;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryId = null),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 16),
                child: Column(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.darkCircle : AppColors.lightCircle,
                        shape: BoxShape.circle,
                        border: isSel ? Border.all(color: AppColors.gold, width: 2) : null,
                      ),
                      child: Icon(Icons.grid_view_rounded, color: isSel ? AppColors.gold : const Color(0xFF8A8A8F), size: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(AppLocalizations.of(context)!.all, style: AppTypography.caption.copyWith(color: isSel ? AppColors.gold : const Color(0xFF8A8A8F))),
                  ],
                ),
              ).animate(delay: 50.ms).fadeIn(duration: 300.ms),
            );
          }
          final cat = categories[i - 1];
          final isSel = _selectedCategoryId == cat.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = cat.id),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Column(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.darkCircle : AppColors.lightCircle,
                      shape: BoxShape.circle,
                      border: isSel ? Border.all(color: AppColors.gold, width: 2) : null,
                    ),
                    child: Icon(IconMapper.getIcon(cat.iconName), color: isSel ? AppColors.gold : const Color(0xFF8A8A8F), size: 24),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 60,
                    child: Text(cat.displayName(context), textAlign: TextAlign.center, style: AppTypography.badge.copyWith(color: isSel ? AppColors.gold : const Color(0xFF8A8A8F))),
                  ),
                ],
              ),
            ).animate(delay: min(50 * i, 400).ms).fadeIn(duration: 300.ms),
          );
        },
      ),
    );
  }



  Widget _buildProductsRow(BuildContext context, List<ProductEntity> products, List<CategoryEntity> categories) {
    final currency = ref.watch(currencyProvider);
    final wishlistItems = ref.watch(wishlistItemsProvider).valueOrNull ?? [];
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: ProductCard(
              product: ProductCardData(
                id: p.id, name: p.displayName(context), price: p.price,
                originalPrice: p.originalPrice, discountPercent: p.discountPercent,
                images: p.images, rating: p.rating, reviewCount: p.reviewCount,
                stockQuantity: p.stockQuantity, isBestSeller: p.isBestSeller,
                isNew: p.isNew, isExclusive: p.isExclusive,
              ),
              currency: currency,
              width: 170,
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
            ),
          );
        },
      ),
    );
  }
}

class _SubCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: isSelected ? AppColors.gold : const Color(0xFFE0D9D0), width: 1.5),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.gold : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer({required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext c) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.gold,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(color: AppColors.surfaceDark, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: AppShimmer(height: 40, borderRadius: 20)),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: AppShimmer(height: 50, borderRadius: 12)),
            const SizedBox(height: 20),
            AppShimmer(height: 200, borderRadius: 0),
            const SizedBox(height: 24),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: AppShimmer(height: 20, width: 150)),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 16),
                  child: Column(children: [AppShimmer(width: 56, height: 56, borderRadius: 28), const SizedBox(height: 6), AppShimmer(width: 40, height: 10)]),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.62),
                itemBuilder: (_, i) => AppShimmer(height: 260, borderRadius: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
