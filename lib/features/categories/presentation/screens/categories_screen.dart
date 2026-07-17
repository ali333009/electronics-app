import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/models/product_card_data.dart';
import '../../../../core/widgets/load_more_indicator.dart';
import '../../../../core/widgets/app_products_grid_shimmer.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/data/models/category_model.dart';
import '../../../products/presentation/providers/paginated_products_provider.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../products/domain/extensions/product_entity_localization.dart';
import '../../../../core/providers/currency_provider.dart';
import 'package:elct/features/cart/utils/add_to_cart_action.dart';
import 'package:elct/features/wishlist/utils/toggle_wishlist_action.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/login_required_bottom_sheet.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.read(homeRepositoryProvider).getCategories();
});

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String? _selectedCategoryId;
  String _selectedCategoryNameAr = '';
  String _selectedCategoryNameEn = '';
  String _selectedCategoryDesc = '';

  String _localizedCategoryName(BuildContext context) {
    if (_selectedCategoryNameAr.isEmpty) return '';
    return Localizations.localeOf(context).languageCode == 'en'
        ? _selectedCategoryNameEn
        : _selectedCategoryNameAr;
  }

  // Local search query — filters already-loaded products without any Firebase call
  String _searchText = '';
  String _searchQuery = '';
  List<ProductEntity> _lastSearchResults = const [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Only paginate when not searching (search is local, no need to load more)
    if (_searchText.isNotEmpty) return;
    final state = _selectedCategoryId == null
        ? ref.read(paginatedAllProductsProvider)
        : ref.read(paginatedCategoryProductsProvider(_selectedCategoryId!));
    if (state.isLoadingMore || !state.hasMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current >= maxScroll - 200) {
      final notifier = _selectedCategoryId == null
          ? ref.read(paginatedAllProductsProvider.notifier)
          : ref.read(paginatedCategoryProductsProvider(_selectedCategoryId!).notifier);
      notifier.fetchNextPage();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedCategoryNameAr.isEmpty) {
      final loc = AppLocalizations.of(context)!;
      _selectedCategoryNameAr = loc.all;
      _selectedCategoryNameEn = loc.all;
      _selectedCategoryDesc = loc.browseCategories;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    // Default paginated state
    final productsState = _selectedCategoryId == null
        ? ref.watch(paginatedAllProductsProvider)
        : ref.watch(paginatedCategoryProductsProvider(_selectedCategoryId!));

    final isSearching = _searchText.isNotEmpty;
    
    // When searching, use firebaseSearchProvider
    final searchAsync = isSearching && _searchQuery.isNotEmpty
        ? ref.watch(firebaseSearchProvider(_searchQuery))
        : null;
    final searchResults = searchAsync?.valueOrNull;
    if (searchResults != null && _searchQuery.isNotEmpty) {
      _lastSearchResults = searchResults;
    }

    final displayedItems = isSearching
        ? (_searchQuery.isEmpty
              ? (_lastSearchResults.isNotEmpty
                    ? _lastSearchResults
                    : productsState.items)
              : (searchResults ?? _lastSearchResults))
        : productsState.items;

    final isLoading = isSearching ? false : productsState.isLoading;
    final isSearchLoading =
        isSearching && (searchAsync?.isLoading ?? _searchQuery.isEmpty);
    final error = isSearching && _searchQuery.isNotEmpty
        ? searchAsync?.error?.toString()
        : productsState.error;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppLocalizations.of(context)!.categories,
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
      body: categoriesAsync.when(
        loading: () => const _CategorySidebarShimmer(),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.errorPrefix(e.toString()), style: const TextStyle(color: AppColors.textSecondary))),
        data: (categories) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              color: AppColors.surfaceCard,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _buildCategoryItem(null, AppLocalizations.of(context)!.all, AppLocalizations.of(context)!.all, Icons.grid_view_rounded),
                  const Divider(color: AppColors.divider, height: 1),
                  ...categories.map((cat) => _buildCategoryItem(cat.id, cat.nameAr, cat.nameEn, IconMapper.getIcon(cat.iconName),
                      imageUrl: cat.imageUrl)),
                ],
              ),
            ),
            Expanded(
              child: _buildProductsPanel(isLoading, isSearchLoading, error, productsState.isLoadingMore, productsState.hasMore, displayedItems, categories),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsPanel(
    bool isLoading,
    bool isSearchLoading,
    String? error,
    bool isLoadingMore,
    bool hasMore,
    List<ProductEntity> displayedItems,
    List<CategoryModel> categories,
  ) {
    if (isLoading) return const AppProductsGridShimmer();
    if (error != null && displayedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.errorPrefix(error),
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 160,
              child: AppButton(
                text: AppLocalizations.of(context)!.retry,
                onPressed: () {
                  ref.invalidate(categoriesProvider);
                  final notifier = _selectedCategoryId == null
                      ? ref.read(paginatedAllProductsProvider.notifier)
                      : ref.read(paginatedCategoryProductsProvider(_selectedCategoryId!).notifier);
                  notifier.refresh();
                },
              ),
            ),
          ],
        ),
      );
    }

    final isSearching = _searchText.isNotEmpty;
    final isEmpty = displayedItems.isEmpty && !isLoadingMore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchBar(isSearchLoading),
        _buildHeader(displayedItems.length),
        Expanded(
          child: isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        isSearching
                            ? AppLocalizations.of(context)!.noProducts
                            : AppLocalizations.of(context)!.noProducts,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    if (isSearching) return; // Don't refresh pagination while searching
                    ref.invalidate(categoriesProvider);
                    final notifier = _selectedCategoryId == null
                        ? ref.read(paginatedAllProductsProvider.notifier)
                        : ref.read(paginatedCategoryProductsProvider(_selectedCategoryId!).notifier);
                    await notifier.refresh();
                  },
                  color: AppColors.gold,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.55,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => _buildProductItem(displayedItems[i]),
                            childCount: displayedItems.length,
                          ),
                        ),
                      ),
                      // Only show load more when not searching
                      if (!isSearching)
                        SliverToBoxAdapter(
                          child: LoadMoreIndicator(
                            isLoadingMore: isLoadingMore,
                            hasMore: hasMore,
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildHeader(int productCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _localizedCategoryName(context),
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.textWhite.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.itemsCount(productCount),
                    style: AppTypography.badge.copyWith(
                      color: AppColors.textWhiteMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCategoryDesc,
              style: AppTypography.caption.copyWith(
                color: AppColors.textWhite.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isSearchLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: TextField(
        controller: _searchController,
        // Direct setState — no Firebase call, just filters loaded products locally
        onChanged: _onSearchChanged,
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.searchInSection,
          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: isSearchLoading
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gold,
                    ),
                  ),
                )
              : _searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                  onPressed: () {
                    _searchDebounce?.cancel();
                    _searchController.clear();
                    setState(() {
                      _searchText = '';
                      _searchQuery = '';
                      _lastSearchResults = const [];
                    });
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: AppColors.surfaceCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    setState(() => _searchText = trimmed);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = trimmed;
        if (trimmed.isEmpty) {
          _lastSearchResults = const [];
        }
      });
    });
  }

  Widget _buildCategoryItem(String? id, String labelAr, String labelEn, IconData? icon, {String? imageUrl}) {
    final isSelected = _selectedCategoryId == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = id;
          _selectedCategoryNameAr = labelAr;
          _selectedCategoryNameEn = labelEn;
          _selectedCategoryDesc = labelEn.isNotEmpty ? AppLocalizations.of(context)!.browseCollection(labelAr) : AppLocalizations.of(context)!.browseCategories;
          _searchDebounce?.cancel();
          _searchText = '';
          _searchQuery = '';
          _lastSearchResults = const [];
          _searchController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.darkCircle : AppColors.lightCircle,
                border: isSelected ? Border.all(color: AppColors.gold, width: 2) : null,
              ),
              child: imageUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 100,
                        memCacheHeight: 100,
                        errorWidget: (_, _, _) => Icon(icon ?? Icons.category_outlined,
                            color: isSelected ? AppColors.gold : AppColors.textSecondary, size: 20),
                      ),
                    )
                  : Icon(icon,
                      color: isSelected ? AppColors.gold : AppColors.textSecondary, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              Localizations.localeOf(context).languageCode == 'en' ? labelEn : labelAr,
              style: AppTypography.caption.copyWith(
                fontSize: 9,
                color: isSelected ? AppColors.gold : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(ProductEntity product) {
    final currency = ref.watch(currencyProvider);
    final wishlistItems = ref.watch(wishlistItemsProvider).valueOrNull ?? [];
    final p = product;
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
  }
}

class _CategorySidebarShimmer extends StatelessWidget {
  const _CategorySidebarShimmer();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 80,
          color: AppColors.surfaceCard,
          child: const Column(
            children: [
              SizedBox(height: 12),
              AppShimmer(width: 48, height: 48, borderRadius: 24),
              SizedBox(height: 20),
              AppShimmer(width: 48, height: 48, borderRadius: 24),
              SizedBox(height: 20),
              AppShimmer(width: 48, height: 48, borderRadius: 24),
            ],
          ),
        ),
        const Expanded(child: AppProductsGridShimmer()),
      ],
    );
  }
}
