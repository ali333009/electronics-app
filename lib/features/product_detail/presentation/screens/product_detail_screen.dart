import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/widgets/login_required_bottom_sheet.dart';
import 'package:elct/features/cart/utils/add_to_cart_action.dart';
import 'package:elct/features/wishlist/utils/toggle_wishlist_action.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/domain/extensions/product_entity_localization.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../widgets/image_header.dart';
import '../widgets/product_info_section.dart';
import '../widgets/description_section.dart';
import '../widgets/specs_section.dart';
import '../widgets/reviews_section_v2.dart';
import '../widgets/similar_products_section_v2.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/detail_shimmer.dart';
import 'package:elct/l10n/app_localizations.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  final Map<String, String> _selectedOptions = {};
  late AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
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
    final productAsync = ref.watch(productDetailProvider(widget.productId));
    final wishlistAsync = ref.watch(wishlistItemsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final userId = user?.uid;
    final userName = user?.displayName ?? 
        (user != null && user.firstName != null ? '${user.firstName} ${user.lastName ?? ''}'.trim() : null) ?? 
        user?.email?.split('@').first;
    return productAsync.when(
      loading: () => const DetailShimmer(),
      error: (e, _) => _buildError(e),
      data: (product) {
        final wishlistItems = wishlistAsync.valueOrNull ?? [];
        final isInWishlist = wishlistItems.any(
          (item) => item.productId == product.id,
        );
        return _buildBody(product, isInWishlist, userId, userName);
      },
    );
  }

  Scaffold _buildError(Object e) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                AppLocalizations.of(context)!.errorPrefix(e.toString()),
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold _buildBody(
    ProductEntity product,
    bool isInWishlist,
    String? userId,
    String? userName,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(productDetailProvider(widget.productId));
                      ref.invalidate(wishlistItemsProvider);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImageHeader(
                            productId: product.id,
                            images: product.images,
                          ),
                          if (product.stockQuantity == 0)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              color: AppColors.error,
                              child: Text(
                                AppLocalizations.of(context)!.outOfStock,
                                textAlign: TextAlign.center,
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ProductInfoSection(product: product),
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(color: AppColors.divider, height: 1)),
                          // ── Variant selectors ────────────────────────
                          ...product.options.entries
                              .where((e) => e.value.isNotEmpty)
                              .map((entry) {
                            return _VariantSelector(
                              label: entry.key,
                              options: entry.value,
                              selected: _selectedOptions[entry.key],
                              onSelect: (v) {
                                setState(() {
                                  _selectedOptions[entry.key] = v;
                                });
                              },
                            );
                          }),
                          DescriptionSection(
                            description: product.displayDescription(context),
                          ),
                          if (product.specs.isNotEmpty) ...[
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(color: AppColors.divider, height: 1)),
                            SpecsSection(specs: product.specs),
                          ],
                          const Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Divider(color: AppColors.divider, height: 1)),
                          ReviewsSectionV2(productId: product.id, userId: userId, userName: userName),
                          if (product.categoryId.isNotEmpty)
                            SimilarProductsSectionV2(
                              categoryId: product.categoryId,
                              currentProductId: product.id,
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  // Pinned Top Floating Buttons
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFloatingButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary,
                          onTap: () => context.pop(),
                        ),
                        _buildFloatingButton(
                          icon: isInWishlist
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isInWishlist
                              ? AppColors.error
                              : AppColors.textPrimary,
                          onTap: () {
                            _animateHeart();
                            _toggleWishlist(product, userId, isInWishlist);
                          },
                          heartController: _heartController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BottomBar(
              product: product,
              quantity: _quantity,
              stockQuantity: product.stockQuantity,
              onDecrement: () {
                if (_quantity > 1) setState(() => _quantity--);
              },
              onIncrement: () {
                if (_quantity < product.stockQuantity) {
                  setState(() => _quantity++);
                }
              },
              onAddToCart: () async => _addToCart(product, userId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    AnimationController? heartController,
  }) {
    Widget iconWidget = Icon(icon, color: color, size: 22);

    if (heartController != null) {
      iconWidget = AnimatedBuilder(
        animation: heartController,
        builder: (context, child) {
          final t = heartController.value;
          final scale = t < 0.5
              ? 1.0 - (t * 0.6)
              : 0.7 + ((t - 0.5) * 0.6);
          return Transform.scale(scale: scale, child: child);
        },
        child: iconWidget,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: iconWidget,
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(ProductEntity product, String? userId) async {
    // If product has options with values, force selection for all of them
    for (final entry in product.options.entries) {
      if (entry.value.isEmpty) continue;
      if (!_selectedOptions.containsKey(entry.key)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الرجاء اختيار ${entry.key} أولاً'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }
    final success = await addToCartAction(
      ref: ref, context: context,
      productId: product.id, nameAr: product.nameAr, nameEn: product.nameEn,
      image: product.images.isNotEmpty ? product.images.first : '',
      price: product.price, originalPrice: product.originalPrice,
      discountPercent: product.discountPercent, stockQuantity: product.stockQuantity,
      quantity: _quantity,
      selectedOptions: _selectedOptions,
      showToast: false,
      onSuccess: () {
        if (mounted) {
          setState(() {
            _quantity = 1;
            _selectedOptions.clear();
          });
        }
      },
    );
    if (success && mounted) {
      _showAddedToCartDialog(product);
    }
  }

  void _showAddedToCartDialog(ProductEntity product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _AddedToCartSheet(
        product: product,
        quantity: _quantity,
        onContinue: () => Navigator.of(ctx).pop(),
        onCheckout: () {
          Navigator.of(ctx).pop();
          context.go('/cart');
        },
      ),
    );
  }

  Future<void> _toggleWishlist(
    ProductEntity product,
    String? userId,
    bool isInWishlist,
  ) async {
    if (userId == null) {
      showLoginRequiredSheet(context, redirectPath: '/products/${product.id}');
      return;
    }
    await toggleWishlistAction(
      ref: ref, context: context, userId: userId,
      productId: product.id, nameAr: product.nameAr, nameEn: product.nameEn,
      image: product.images.isNotEmpty ? product.images.first : '',
      price: product.price, originalPrice: product.originalPrice,
      discountPercent: product.discountPercent,
      rating: product.rating, reviewCount: product.reviewCount,
      stockQuantity: product.stockQuantity,
      isInWishlist: isInWishlist,
    );
  }
}

/// Reusable variant selector (colors / sizes) widget
class _VariantSelector extends StatelessWidget {
  final String label;
  final List<OptionItem> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _VariantSelector({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  bool get _isColorOption => label == 'اللون' && options.any((o) => o.hex != null);

  static Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final clean = hex.replaceFirst('#', '');
      if (clean.length != 6) return null;
      return Color(int.parse('0xFF$clean'));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              if (selected != null) ...[
                const SizedBox(width: 8),
                Text(
                  selected!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = opt.name == selected;
              if (_isColorOption) {
                return GestureDetector(
                  onTap: () => onSelect(opt.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _parseHexColor(opt.hex) ?? AppColors.divider,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.gold : AppColors.divider,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }
              return GestureDetector(
                onTap: () => onSelect(opt.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.gold : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.gold : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    opt.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AddedToCartSheet extends ConsumerStatefulWidget {
  final ProductEntity product;
  final int quantity;
  final VoidCallback onContinue;
  final VoidCallback onCheckout;

  const _AddedToCartSheet({
    required this.product,
    required this.quantity,
    required this.onContinue,
    required this.onCheckout,
  });

  @override
  ConsumerState<_AddedToCartSheet> createState() => _AddedToCartSheetState();
}

class _AddedToCartSheetState extends ConsumerState<_AddedToCartSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.5),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final name = product.nameAr.isNotEmpty ? product.nameAr : product.nameEn;
    final priceFmt = product.price.formatPrice(
      ref.read(currencyProvider),
    );

    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, _) {
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Drag handle ──
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // ── Animated check ring ──
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Title ──
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    AppLocalizations.of(context)!.addToCartSuccess,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Mini product card ──
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // Product image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 56,
                            height: 56,
                            color: AppColors.surfaceLight,
                            child: product.images.isNotEmpty
                                ? Image.network(
                                    product.images.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, e, st) => const Icon(
                                      Icons.shopping_bag_outlined,
                                      color: AppColors.textMuted,
                                      size: 24,
                                    ),
                                  )
                                : const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: AppColors.textMuted,
                                    size: 24,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name + price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '$priceFmt × ${widget.quantity}',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (product.price * widget.quantity).formatPrice(
                                      ref.read(currencyProvider),
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Qty badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '×${widget.quantity}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Buttons ──
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Checkout button (primary)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: widget.onCheckout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                              shadowColor: AppColors.gold.withValues(alpha: 0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_cart_checkout_outlined, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.checkout,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Continue shopping button (secondary)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: widget.onContinue,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: BorderSide(
                                color: AppColors.divider,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.continueShopping,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
