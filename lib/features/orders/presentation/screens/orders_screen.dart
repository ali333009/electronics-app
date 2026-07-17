import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/providers/currency_provider.dart';
import '../providers/orders_provider.dart';
import '../../domain/entities/order_entity.dart';
import '../../../checkout/domain/extensions/order_item_entity_localization.dart';
import 'package:elct/l10n/app_localizations.dart';

enum OrderFilter { all, placed, processing, delivered, cancelled }

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  OrderFilter _activeFilter = OrderFilter.all;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersListProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward : Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elegant Header Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              AppLocalizations.of(context)!.myOrders,
              style: AppTypography.displayMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.textPrimary,
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
          
          const SizedBox(height: 12),

          // Orders Content depending on state
          Expanded(
            child: ordersAsync.when(
              loading: () => const _OrdersShimmer(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
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
                        onPressed: () => ref.invalidate(ordersListProvider),
                      ),
                    ],
                  ),
                ),
              ),
              data: (orders) {
                // Filter logic
                final filteredOrders = orders.where((order) {
                  switch (_activeFilter) {
                    case OrderFilter.all:
                      return true;
                    case OrderFilter.placed:
                      return order.status == OrderStatus.pending;
                    case OrderFilter.processing:
                      return order.status == OrderStatus.confirmed ||
                             order.status == OrderStatus.shipped;
                    case OrderFilter.delivered:
                      return order.status == OrderStatus.delivered;
                    case OrderFilter.cancelled:
                      return order.status == OrderStatus.cancelled;
                  }
                }).toList();

                return Column(
                  children: [
                    // Horizontal Luxury Filters Scrollable Bar
                    _buildFiltersBar(orders),
                    const SizedBox(height: 12),
                    
                    // Orders List
                    Expanded(
                      child: filteredOrders.isEmpty
                          ? _buildEmptyState(context)
                          : RefreshIndicator(
                              onRefresh: () => ref.refresh(ordersListProvider.future),
                              color: AppColors.gold,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                itemCount: filteredOrders.length,
                                itemBuilder: (context, i) {
                                  final order = filteredOrders[i];
                                  return _buildOrderCard(order: order, context: context)
                                      .animate(delay: min(40 * i, 400).ms)
                                      .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                                      .slide(begin: const Offset(0, 0.05), duration: 300.ms, curve: Curves.easeOut);
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Luxury Filters Scrollable Bar ─────────────────────────────────────────
  Widget _buildFiltersBar(List<OrderEntity> allOrders) {
    // Helper to count orders per filter type
    int countForFilter(OrderFilter filter) {
      if (filter == OrderFilter.all) return allOrders.length;
      return allOrders.where((order) {
        switch (filter) {
          case OrderFilter.placed:
            return order.status == OrderStatus.pending;
          case OrderFilter.processing:
            return order.status == OrderStatus.confirmed ||
                   order.status == OrderStatus.shipped;
          case OrderFilter.delivered:
            return order.status == OrderStatus.delivered;
          case OrderFilter.cancelled:
            return order.status == OrderStatus.cancelled;
          default:
            return false;
        }
      }).length;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(OrderFilter.all, AppLocalizations.of(context)!.all, countForFilter(OrderFilter.all)),
          _buildFilterChip(OrderFilter.placed, 'تم الطلب', countForFilter(OrderFilter.placed)),
          _buildFilterChip(OrderFilter.processing, 'قيد المعالجة', countForFilter(OrderFilter.processing)),
          _buildFilterChip(OrderFilter.delivered, 'تم التوصيل', countForFilter(OrderFilter.delivered)),
          _buildFilterChip(OrderFilter.cancelled, 'ملغي', countForFilter(OrderFilter.cancelled)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(OrderFilter filter, String title, int count) {
    final isSelected = _activeFilter == filter;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _activeFilter = filter;
              });
              HapticFeedback.selectionClick();
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? AppColors.gold : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
                gradient: isSelected ? LinearGradient(
                  colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ) : null,
                color: isSelected ? null : Colors.white,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  Text(
                    title,
                    style: AppTypography.captionBold.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.25) : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: AppTypography.badge.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Premium Order Card ────────────────────────────────────────────────────
  Widget _buildOrderCard({required OrderEntity order, required BuildContext context}) {
    final currency = ref.read(currencyProvider);
    final statusColor = _statusColor(order.status);
    final dateStr = DateFormatter.dateOnly(order.createdAt);
    
    // Grab first item's image and details for preview
    final hasItems = order.items.isNotEmpty;
    final firstItem = hasItems ? order.items.first : null;
    final remainingCount = order.items.length - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Header Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.orderNumber(order.id.toUpperCase()),
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: AppTypography.badge.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(order.status),
                    style: AppTypography.badge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: AppColors.border),

          // Order Items Preview Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Product preview image
                if (firstItem != null)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.network(
                      firstItem.image,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(Icons.shopping_bag_outlined, color: AppColors.textMuted),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textMuted),
                  ),
                
                const SizedBox(width: 12),

                // Order summary details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem != null ? firstItem.displayName(context) : AppLocalizations.of(context)!.product,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                      remainingCount > 0 
                          ? AppLocalizations.of(context)!.andOtherProducts(remainingCount.toString())
                          : AppLocalizations.of(context)!.productCount('1'),
                        style: AppTypography.badge.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (firstItem != null && firstItem.selectedOptions != null && firstItem.selectedOptions!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: firstItem.selectedOptions!.entries.map((e) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                '${e.key}: ${e.value}',
                                style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Total price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.total,
                      style: AppTypography.badge.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatPrice(order.total, currency),
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, color: AppColors.border),
          
          // Card Footer/Action
          InkWell(
            onTap: () => context.push('${Routes.orders}/${order.id}'),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
                  child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.orderDetails,
                    style: AppTypography.captionBold.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'تم الطلب';
      case OrderStatus.confirmed:
      case OrderStatus.shipped:
        return 'قيد المعالجة';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return const Color(0xFFC59B27); // Luxury Warm Amber
      case OrderStatus.shipped:
        return const Color(0xFF3F8CFF); // Royal Blue
      case OrderStatus.delivered:
        return const Color(0xFF2E8B57); // Deep Emerald Green
      case OrderStatus.cancelled:
        return const Color(0xFFD93838); // Premium Crimson Red
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: AppColors.textMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noOrders,
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.noOrdersDesc,
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            child: AppButton(
              text: AppLocalizations.of(context)!.goShopping,
              onPressed: () => context.go(Routes.home),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersShimmer extends StatelessWidget {
  const _OrdersShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: 3,
      itemBuilder: (_, _) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer(width: 120, height: 16),
                    const SizedBox(height: 6),
                    AppShimmer(width: 80, height: 12),
                  ],
                ),
                AppShimmer(width: 70, height: 24, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                AppShimmer(width: 60, height: 60, borderRadius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmer(width: 150, height: 14),
                      const SizedBox(height: 8),
                      AppShimmer(width: 90, height: 12),
                    ],
                  ),
                ),
                AppShimmer(width: 60, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
