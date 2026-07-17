import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../features/products/presentation/providers/products_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/models/currency.dart';
import '../providers/cart_provider.dart';
import '../providers/guest_cart_provider.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/extensions/cart_item_entity_localization.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/pending_redirect_provider.dart';
import 'package:elct/l10n/app_localizations.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isCheckingOut = false;

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartItemsProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppLocalizations.of(context)!.cartTitle,
          style: AppTypography.headlineMedium,
        ),
        actions: [
          cartAsync.valueOrNull != null && cartAsync.valueOrNull!.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.gold,
                    size: 22,
                  ),
                  onPressed: () => _clearCart(context, ref),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: cartAsync.when(
        loading: () => const _CartShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.errorPrefix(e.toString()),
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: AppLocalizations.of(context)!.retry,
                onPressed: () => ref.invalidate(cartItemsProvider),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) return _buildEmptyState(context);
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(cartItemsProvider);
            },
            color: AppColors.gold,
            child: _buildCartList(context, ref, items),
          ).animate().fadeIn(duration: 300.ms);
        },
      ),
      bottomNavigationBar:
          cartAsync.valueOrNull != null && cartAsync.valueOrNull!.isNotEmpty
          ? _buildBottomBar(context, ref, total, cartAsync.valueOrNull!)
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppLocalizations.of(context)!.cartEmpty,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppLocalizations.of(context)!.cartEmptySubtitle,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: AppButton(
              text: AppLocalizations.of(context)!.continueShopping,
              onPressed: () => context.go(Routes.home),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context,
    WidgetRef ref,
    List<CartItemEntity> items,
  ) {
    final currency = ref.watch(currencyProvider);
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final atMax = item.stockQuantity > 0 && item.quantity >= item.stockQuantity;
        return _CartItemCard(
              item: item,
              currency: currency,
              atMax: atMax,
              onTap: () => context.push('${Routes.products}/${item.productId}'),
              onIncrement: () => _updateQuantity(ref, item, item.quantity + 1),
              onDecrement: () => _updateQuantity(ref, item, item.quantity - 1),
              onDelete: () => _removeItem(context, ref, item),
            )
            .animate(delay: min(50 * index, 400).ms)
            .fadeIn(duration: 300.ms, curve: Curves.easeOut)
            .slide(
              begin: const Offset(0, 0.1),
              duration: 300.ms,
              curve: Curves.easeOut
            );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    double total,
    List<CartItemEntity> items,
  ) {
    final currency = ref.watch(currencyProvider);
    final hasOutOfStock = items.any((i) => i.stockQuantity == 0);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.total,
                  style: AppTypography.titleLarge,
                ),
                Text(
                  formatPrice(total, currency),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              text: AppLocalizations.of(context)!.checkout,
              isLoading: _isCheckingOut,
              onPressed: hasOutOfStock
                  ? () => AppToast.show(
                      context,
                      AppLocalizations.of(context)!.removeOutOfStockItems,
                      icon: Icons.warning_amber_rounded,
                    )
                  : _isCheckingOut
                      ? null
                      : () => _goToCheckout(context, ref, items),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(WidgetRef ref, CartItemEntity item, int qty) {
    if (qty < 1) return;
    // Never exceed available stock
    if (qty > item.stockQuantity && item.stockQuantity > 0) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ref.read(guestCartProvider.notifier).updateQuantity(item.productId, qty);
      return;
    }
    ref.read(cartRepositoryProvider).updateQuantity(userId, item.id, qty);
  }

  Future<void> _goToCheckout(
    BuildContext context,
    WidgetRef ref,
    List<CartItemEntity> items,
  ) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ref.read(pendingRedirectProvider.notifier).state = Routes.checkout;
      context.push(Routes.login);
      return;
    }

    setState(() => _isCheckingOut = true);
    try {
      for (final item in items) {
        final product =
            await ref.read(productsRepositoryProvider).getProductById(item.productId);
        final currentStock = product.stockQuantity;
        if (currentStock < item.quantity) {
          if (!context.mounted) return;
          AppToast.show(
            context,
            AppLocalizations.of(context)!.quantityUnavailable,
            icon: Icons.warning_amber_rounded,
          );
          return;
        }

        if (product.price != item.price) {
          if (!context.mounted) return;
          AppToast.show(
            context,
            AppLocalizations.of(context)!
                .cartError('تغير سعر بعض المنتجات. أعد إضافة المنتج للسلة.'),
            icon: Icons.warning_amber_rounded,
          );
          return;
        }
      }

      if (!context.mounted) return;
      context.push(Routes.checkout);
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(
        context,
        AppLocalizations.of(context)!.cartError(e.toString()),
        icon: Icons.error_outline,
      );
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  void _removeItem(BuildContext context, WidgetRef ref, CartItemEntity item) {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ref.read(guestCartProvider.notifier).removeItem(item.productId);
      AppToast.show(
        context,
        AppLocalizations.of(context)!.itemDeleted,
        icon: Icons.delete_outline,
      );
      return;
    }
    ref.read(cartRepositoryProvider).removeItem(userId, item.id);
    AppToast.show(
      context,
      AppLocalizations.of(context)!.itemDeleted,
      icon: Icons.delete_outline,
    );
  }

  void _clearCart(BuildContext context, WidgetRef ref) {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      ref.read(guestCartProvider.notifier).clear();
      AppToast.show(
        context,
        AppLocalizations.of(context)!.cartCleared,
        icon: Icons.remove_circle_outline,
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              AppLocalizations.of(context)!.clearCartTitle,
              style: AppTypography.headlineMedium,
            ),
            content: Text(
              AppLocalizations.of(context)!.clearCartConfirm,
              style: AppTypography.bodyMedium,
            ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(context)!.cancel,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(cartRepositoryProvider).clearCart(userId);
                Navigator.pop(ctx);
                AppToast.show(
                  context,
                  AppLocalizations.of(context)!.cartCleared,
                  icon: Icons.remove_circle_outline,
                );
              },
              child: Text(
                AppLocalizations.of(context)!.deleteAll,
                style: AppTypography.labelLarge.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onTap;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final Currency currency;
  final bool atMax;

  const _CartItemCard({
    required this.item,
    required this.onTap,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    required this.currency,
    required this.atMax,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isOutOfStock = item.stockQuantity == 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOutOfStock
                ? AppColors.error
                : AppColors.gold.withValues(alpha: 0.2),
            width: isOutOfStock ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Right side in RTL (Image)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 85,
                height: 85,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFAF7F3), Color(0xFFEADBCE)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: item.image,
                  fit: BoxFit.cover,
                  memCacheWidth: 170,
                  memCacheHeight: 170,
                  placeholder: (_, _) => const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gold,
                    ),
                  ),
                  errorWidget: (_, _, _) => const Center(
                    child: Icon(
                      Icons.checkroom_outlined,
                      size: 28,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 2. Middle Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: isRtl
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: AppTypography.bodyLargeBold.copyWith(height: 1.3),
                  ),
                  if (item.selectedOptions != null && item.selectedOptions!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: item.selectedOptions!.entries.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Price row
                  Row(
                    mainAxisAlignment: isRtl
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (item.originalPrice != null) ...[
                        Text(
                          formatPrice(item.originalPrice!, currency),
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted, decoration: TextDecoration.lineThrough),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        formatPrice(item.price, currency),
                        style: AppTypography.bodyLargeBold.copyWith(
                          color: isOutOfStock ? AppColors.textMuted : AppColors.gold,
                        ),
                      ),
                      if (isOutOfStock) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.outOfStock,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Stock badge + Quantity Selector
                  Row(
                    children: [
                      // Quantity Selector Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4F0),
                          borderRadius: BorderRadius.circular(30),
                          border: isOutOfStock
                              ? Border.all(
                                  color: AppColors.error.withValues(alpha: 0.3),
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QuantityButton(
                              icon: Icons.remove,
                              onTap: isOutOfStock ? () {} : onDecrement,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Text(
                                  '${item.quantity}',
                                  key: ValueKey(item.quantity),
                                  style: AppTypography.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isOutOfStock
                                        ? AppColors.textMuted
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            _QuantityButton(
                              icon: Icons.add,
                              onTap: (isOutOfStock || atMax) ? () {} : onIncrement,
                              disabled: isOutOfStock || atMax,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Stock label next to qty pill
                      if (!isOutOfStock)
                        Flexible(
                          child: _StockBadge(stockQuantity: item.stockQuantity),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 3. Left side in RTL (Delete Button)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: disabled
              ? AppColors.textMuted.withValues(alpha: 0.35)
              : AppColors.surfaceDark,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stockQuantity;
  const _StockBadge({required this.stockQuantity});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color color;
    final String label;
    final IconData iconData;

    if (stockQuantity == 1) {
      color = AppColors.error;
      label = l10n.lastPieceAlert;
      iconData = Icons.local_fire_department_rounded;
    } else if (stockQuantity <= 5) {
      color = const Color(0xFFE07B00);
      label = l10n.lowStockAlert(stockQuantity);
      iconData = Icons.warning_amber_rounded;
    } else {
      color = AppColors.textSecondary;
      label = l10n.stockAvailable(stockQuantity);
      iconData = Icons.inventory_2_outlined;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(stockQuantity),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 11, color: color),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartShimmer extends StatelessWidget {
  const _CartShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Row(
        children: [
          AppShimmer(width: 85, height: 85, borderRadius: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmer(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                AppShimmer(width: 100, height: 16),
                const SizedBox(height: 8),
                AppShimmer(width: 140, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
