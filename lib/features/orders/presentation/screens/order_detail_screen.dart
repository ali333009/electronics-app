import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/models/currency.dart';
import '../providers/orders_provider.dart';
import '../../../checkout/domain/entities/order_entity.dart';
import '../../../checkout/domain/extensions/order_item_entity_localization.dart';
import 'package:elct/l10n/app_localizations.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final currency = ref.watch(currencyProvider);
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final l10n = AppLocalizations.of(context)!;
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
      body: userId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.loginRequired, style: AppTypography.bodyLarge),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(text: l10n.login, onPressed: () => context.push(Routes.login)),
                ],
              ),
            )
          : orderAsync.when(
        loading: () => const _OrderDetailShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.loadErrorPrefix(e.toString()), style: AppTypography.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              AppButton(text: l10n.retry, onPressed: () => ref.invalidate(orderDetailProvider(orderId))),
            ],
          ),
        ),
        data: (order) => _buildContent(context, ref, orderId, l10n, order, currency),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, String orderId, AppLocalizations l10n, OrderEntity order, Currency currency) {
    return RefreshIndicator(
      color: AppColors.gold,
      onRefresh: () {
        ref.invalidate(orderDetailProvider(orderId));
        return ref.read(orderDetailProvider(orderId).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Elegant Header Title
          Text(
            l10n.orderDetail,
            style: AppTypography.displayMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
          const SizedBox(height: 24),

          // Status & Timeline Tracker Card
          _buildStatusTrackerCard(context, order, l10n),
          const SizedBox(height: 24),

          // Products List Section
          _buildSectionTitle(l10n.orderDetailProducts),
          const SizedBox(height: 12),
          ...order.items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return _buildItemCard(context, l10n, item, currency)
                .animate(delay: min(40 * i, 400).ms)
                .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                .slide(begin: const Offset(0, 0.05), duration: 300.ms, curve: Curves.easeOut);
          }),
          const SizedBox(height: 24),

          // Shipping details card
          _buildSectionTitle(l10n.shipping),
          const SizedBox(height: 12),
          _buildAddressCard(context, order.shippingAddress),
          const SizedBox(height: 24),

          // Order summary card
          _buildSectionTitle(l10n.orderSummary),
          const SizedBox(height: 12),
          _buildSummaryCard(l10n, order, currency),
        ],
      ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.labelLarge.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ─── Status & Timeline Tracker Card ────────────────────────────────────────
  Widget _buildStatusTrackerCard(BuildContext context, OrderEntity order, AppLocalizations l10n) {
    final color = _statusColor(order.status);
    
    // Status tracking step details
    int currentStep = 0;
    if (order.status == OrderStatus.confirmed) currentStep = 1;
    if (order.status == OrderStatus.shipped) currentStep = 1;
    if (order.status == OrderStatus.delivered) currentStep = 2;
    if (order.status == OrderStatus.cancelled) currentStep = -1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.orderNumber(order.id.toUpperCase()),
                        style: AppTypography.bodyLargeBold.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: order.id));
                          AppToast.show(context, l10n.orderNumberCopied, icon: Icons.copy);
                          HapticFeedback.lightImpact();
                        },
                        child: const Icon(Icons.copy, size: 14, color: AppColors.gold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.trackerSubtitle,
                    style: AppTypography.badge.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _statusLabel(order.status, l10n),
                  style: AppTypography.captionBold.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          
          if (currentStep >= 0) ...[
            const SizedBox(height: 24),
            // Progress tracker lines
            Row(
              children: [
                _buildTrackerNode(l10n.orderStatusPlaced, currentStep >= 0),
                _buildTrackerLine(currentStep >= 1),
                _buildTrackerNode(l10n.orderStatusProcessing, currentStep >= 1),
                _buildTrackerLine(currentStep >= 2),
                _buildTrackerNode(l10n.orderStatusDeliveredLabel, currentStep >= 2),
              ],
            ),
          ] else ...[
            const SizedBox(height: 20),
            // Cancelled indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
              ),
                  child: Row(
                children: [
                  const Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.orderCancelledMessage,
                      style: AppTypography.badge.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackerNode(String label, bool isActive) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.gold : Colors.white,
            border: Border.all(
              color: isActive ? AppColors.gold : AppColors.border,
              width: isActive ? 0 : 2,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 6,
              )
            ] : null,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.textPrimary : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackerLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24, left: 4, right: 4),
        color: isActive ? AppColors.gold : AppColors.border,
      ),
    );
  }

  // ─── Luxurious Item Card ───────────────────────────────────────────────────
  Widget _buildItemCard(BuildContext context, AppLocalizations l10n, OrderItemEntity item, Currency currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.image,
                fit: BoxFit.contain,
                memCacheWidth: 120,
                memCacheHeight: 120,
                placeholder: (_, _) => Container(color: AppColors.surfaceLight),
                errorWidget: (_, _, _) => const Icon(Icons.shopping_bag_outlined, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName(context),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.itemQuantity(item.quantity),
                style: AppTypography.badge.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
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
          Text(
            formatPrice(item.total, currency),
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shipping & Address Card with static OSM Map Preview ────────────────────
  Widget _buildAddressCard(BuildContext context, ShippingAddressEntity address) {
    // Attempt to parse coordinates from the label
    double? lat;
    double? lng;
    if (address.label != null && address.label!.contains(',')) {
      final parts = address.label!.split(',');
      if (parts.length >= 3) {
        lat = double.tryParse(parts[1]);
        lng = double.tryParse(parts[2]);
      } else if (parts.length == 2) {
        lat = double.tryParse(parts[0]);
        lng = double.tryParse(parts[1]);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddressRow(Icons.person_outline_rounded, AppLocalizations.of(context)!.fullName, address.name),
          const Divider(height: 20, color: AppColors.border),
          _buildAddressRow(Icons.phone_iphone_rounded, AppLocalizations.of(context)!.phoneNumber, address.phone),
          const Divider(height: 20, color: AppColors.border),
          _buildAddressRow(Icons.location_on_outlined, AppLocalizations.of(context)!.city, address.city),
          const Divider(height: 20, color: AppColors.border),
          _buildAddressRow(Icons.map_outlined, AppLocalizations.of(context)!.address, address.address),

          // Show static interactive map preview if coords exist
          if (lat != null && lng != null) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.deliveryLocation,
              style: AppTypography.badge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(lat, lng),
                    initialZoom: 13.0,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.elct',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.error,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.gold),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.badge.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Billing Summary Card ──────────────────────────────────────────────────
  Widget _buildSummaryCard(AppLocalizations l10n, OrderEntity order, Currency currency) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow(l10n.subtotal, formatPrice(order.subtotal, currency)),
          const SizedBox(height: 10),
          _buildSummaryRow(
            l10n.shipping,
            order.shipping == 0 ? l10n.free : formatPrice(order.shipping, currency),
            valueColor: order.shipping == 0 ? Colors.green : AppColors.textPrimary,
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(l10n.paymentMethod, order.paymentMethod.toUpperCase() == 'COD' ? l10n.cashOnDelivery : l10n.creditCard),
          const Divider(height: 24, color: AppColors.border),
          _buildSummaryRow(
            l10n.grandTotal,
            formatPrice(order.total, currency),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
            ? AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)
            : AppTypography.caption,
        ),
        Text(
          value,
        style: isTotal
            ? AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: valueColor ?? AppColors.gold)
            : AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary),
        ),
      ],
    );
  }

  String _statusLabel(OrderStatus status, AppLocalizations l10n) {
    switch (status) {
      case OrderStatus.pending:
        return l10n.orderStatusPlaced;
      case OrderStatus.confirmed:
      case OrderStatus.shipped:
        return l10n.orderStatusProcessing;
      case OrderStatus.delivered:
        return l10n.orderStatusDeliveredLabel;
      case OrderStatus.cancelled:
        return l10n.orderStatusCancelledLabel;
    }
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.confirmed:
        return const Color(0xFFC59B27);
      case OrderStatus.shipped:
        return const Color(0xFF3F8CFF);
      case OrderStatus.delivered:
        return const Color(0xFF2E8B57);
      case OrderStatus.cancelled:
        return const Color(0xFFD93838);
    }
  }
}

class _OrderDetailShimmer extends StatelessWidget {
  const _OrderDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer(width: 140, height: 24),
          const SizedBox(height: 16),
          AppShimmer(width: double.infinity, height: 120, borderRadius: 20),
          const SizedBox(height: 24),
          AppShimmer(width: 100, height: 18),
          const SizedBox(height: 12),
          AppShimmer(width: double.infinity, height: 80, borderRadius: 16),
          const SizedBox(height: 24),
          AppShimmer(width: 100, height: 18),
          const SizedBox(height: 12),
          AppShimmer(width: double.infinity, height: 220, borderRadius: 20),
          const SizedBox(height: 24),
          AppShimmer(width: 100, height: 18),
          const SizedBox(height: 12),
          AppShimmer(width: double.infinity, height: 140, borderRadius: 20),
        ],
      ),
    );
  }
}
