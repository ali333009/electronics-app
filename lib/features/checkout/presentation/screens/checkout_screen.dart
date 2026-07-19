import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:elct/core/theme/app_colors.dart';
import 'package:elct/core/theme/app_typography.dart';
import 'package:elct/core/theme/app_spacing.dart';
import 'package:elct/core/widgets/app_button.dart';
import 'package:elct/core/widgets/app_shimmer.dart';
import 'package:elct/core/utils/price_formatter.dart';
import 'package:elct/core/widgets/app_toast.dart';
import 'package:elct/core/providers/currency_provider.dart';
import 'package:elct/core/models/currency.dart';
import 'package:elct/core/router/routes.dart';
import 'package:elct/features/cart/domain/entities/cart_item_entity.dart';
import 'package:elct/features/cart/presentation/providers/cart_provider.dart';
import 'package:elct/features/auth/presentation/providers/auth_provider.dart';
import 'package:elct/features/profile/presentation/providers/profile_provider.dart';
import 'package:elct/features/profile/domain/entities/address_entity.dart';
import 'package:elct/features/profile/data/models/address_model.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/core/firebase/settings_provider.dart';
import '../providers/checkout_controller.dart';
import '../widgets/checkout_address_section.dart';
import '../widgets/checkout_payment_section.dart';
import '../widgets/checkout_order_summary.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUserIdProvider);
    final cartAsync = ref.watch(cartItemsProvider);
    final currency = ref.watch(currencyProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          AppLocalizations.of(context)!.confirmOrder,
          style: AppTypography.headlineMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward : Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: cartAsync.when(
        loading: () => const _CheckoutShimmer(),
        error: (e, _) => _buildError(context, e.toString(), () => ref.invalidate(cartItemsProvider)),
        data: (items) {
          if (items.isEmpty) return _buildEmptyCart(context);
          if (uid == null) return _buildLoginRequired(context);

          return ref.watch(addressesProvider(uid)).when(
            loading: () => const _CheckoutShimmer(),
            error: (e, _) => _buildError(context, e.toString(), () => ref.invalidate(addressesProvider(uid))),
            data: (addresses) {
              return ref.watch(shippingSettingsProvider).when(
                    loading: () => const _CheckoutShimmer(),
                    error: (e, _) => _buildError(
                      context,
                      e.toString(),
                      () => ref.invalidate(shippingSettingsProvider),
                    ),
                    data: (settings) {
                      final state = ref.watch(checkoutControllerProvider);
                      final controller = ref.read(checkoutControllerProvider.notifier);

                      final computedSubtotal = items.fold<num>(0, (sum, item) => sum + item.totalPrice).toDouble();
                      final shipping = state.deliveryType == 'fast'
                        ? settings.fastCostForSubtotal(computedSubtotal)
                        : settings.costForSubtotal(computedSubtotal);
                      final grandTotal = (computedSubtotal - state.couponDiscount) + shipping;

                      return _buildContent(context, items, addresses, computedSubtotal, shipping, grandTotal, settings, state, controller, currency);
                    },
                  );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, 
    List<CartItemEntity> items,
    List<AddressModel> addresses, 
    double subtotal,
    double shipping, 
    double grandTotal, 
    ShippingSettings settings,
    CheckoutState state,
    CheckoutController controller,
    Currency currency,
  ) {
    final singleAddress = addresses.isNotEmpty
        ? (addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first))
        : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckoutAddressSection(address: singleAddress, controller: controller, state: state),
          const SizedBox(height: 24),

          _buildSectionHeader(AppLocalizations.of(context)!.shippingOption),
          const SizedBox(height: 10),
          _buildDeliveryOptionsSection(context, subtotal, settings, currency, state, controller),
          const SizedBox(height: 24),

          CheckoutPaymentSection(controller: controller, state: state),
          const SizedBox(height: 24),

          CheckoutOrderSummary(
            subtotal: subtotal,
            shipping: shipping,
            grandTotal: grandTotal,
            currency: currency,
            items: items,
            controller: controller,
            state: state,
          ),
          const SizedBox(height: 36),

          AppButton(
            text: AppLocalizations.of(context)!.confirmOrder,
            icon: Icons.payment_rounded,
            isLoading: state.isPlacingOrder,
            onPressed: state.isPlacingOrder ? null : (singleAddress == null
                ? () => AppToast.show(context, AppLocalizations.of(context)!.addressRequired, icon: Icons.location_on_outlined)
                : () {
                    if (controller.validateFields(context)) {
                      _showConfirmOrderDialog(context, singleAddress, items, controller);
                    }
                  }),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmOrderDialog(BuildContext context, AddressEntity address, List<CartItemEntity> items, CheckoutController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.gold, size: 24),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(ctx)!.confirmOrder, style: AppTypography.headlineMedium),
          ],
        ),
        content: Text(AppLocalizations.of(ctx)!.confirmOrderMessage, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx)!.cancel, style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(ctx)!.confirm, style: AppTypography.labelLarge.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      controller.placeOrder(context, address, items);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTypography.labelLarge);
  }

  Widget _buildDeliveryOptionsSection(
    BuildContext context,
    double subtotal,
    ShippingSettings settings,
    Currency currency,
    CheckoutState state,
    CheckoutController controller,
  ) {
    final normalCost = settings.costForSubtotal(subtotal);
    final fastCost = settings.fastCostForSubtotal(subtotal);
    final threshold = settings.freeShippingThreshold;
    final isFreeNormal = normalCost == 0;

    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    final deliveryOptions = [
      (
        type: 'normal',
        icon: Icons.local_shipping_outlined,
        label: l10n.standardDeliveryLabel,
        description: isFreeNormal
            ? l10n.freeShippingLabel
            : settings.localizedNormalDescription(locale),
        cost: normalCost,
        color: AppColors.gold,
      ),
      (
        type: 'fast',
        icon: Icons.bolt_rounded,
        label: l10n.expressDeliveryLabel,
        description: settings.localizedExpressDescription(locale),
        cost: fastCost,
        color: const Color(0xFF6366f1),
      ),
    ];

    // Free shipping notice
    final freeNotice = subtotal < threshold && !settings.isAlwaysFree
        ? Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined, color: Colors.green.shade700, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.freeShippingThreshold(formatPrice(threshold - subtotal, currency)),
                    style: TextStyle(color: Colors.green.shade800, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        freeNotice,
        ...deliveryOptions.map((opt) {
          final isSelected = state.deliveryType == opt.type;
          return GestureDetector(
            onTap: () => controller.setDeliveryType(opt.type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? opt.color.withValues(alpha: 0.07) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? opt.color : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(color: opt.color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4)),
                ] : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: opt.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(opt.icon, color: opt.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt.label, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(opt.description, style: AppTypography.badge.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w400), softWrap: true),
                      ],
                    ),
                  ),
                  Text(
                    opt.cost == 0 ? l10n.free : formatPrice(opt.cost, currency),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: opt.cost == 0 ? Colors.green : opt.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? opt.color : Colors.transparent,
                      border: Border.all(color: isSelected ? opt.color : AppColors.border, width: 2),
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                  ),
                ],
              ),
            ),
          );
        }),

        // Date & Time picker
        const SizedBox(height: 8),
        _buildDateTimePicker(context, settings, state, controller),
      ],
    );
  }

  Widget _buildDateTimePicker(BuildContext context, ShippingSettings settings, CheckoutState state, CheckoutController controller) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = state.deliveryDate;
    final selectedTime = state.deliveryTime;
    final isExpress = state.deliveryType == 'fast';

    final count = settings.availableDaysCount;
    final now = DateTime.now();
    final minDate = DateTime(now.year, now.month, now.day);
    final maxDate = minDate.add(Duration(days: (count - 1).clamp(0, 365)));

    bool isDateSelectable(DateTime d) {
      return !d.isBefore(minDate) && !d.isAfter(maxDate);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.calendar_month_outlined, color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            Text(l10n.preferredDeliveryTime, style: AppTypography.labelLarge),
          ]),
          const SizedBox(height: 12),

          // Date picker
          GestureDetector(
            onTap: () async {
              try {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: minDate,
                  firstDate: minDate,
                  lastDate: maxDate,
                  selectableDayPredicate: (d) => isDateSelectable(d),
                  builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(primary: AppColors.gold),
                  ), child: child!),
                );
                if (picked != null) controller.setDeliveryDate(picked);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selectedDate != null ? AppColors.gold.withValues(alpha: 0.07) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selectedDate != null ? AppColors.gold : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.event, color: selectedDate != null ? AppColors.gold : Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    selectedDate != null
                      ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                      : l10n.chooseDate,
                    style: TextStyle(
                      color: selectedDate != null ? AppColors.textPrimary : AppColors.textMuted,
                      fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Time slots (only for express delivery)
          if (isExpress && settings.expressTimeSlots.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: settings.expressTimeSlots.map((slot) {
                final isSelected = slot == selectedTime;
                return GestureDetector(
                  onTap: () => controller.setDeliveryTime(slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.gold : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? AppColors.gold : Colors.grey.shade300),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.emptyCartCheckout, style: AppTypography.headlineMedium),
          const SizedBox(height: 24),
          SizedBox(width: 200, child: AppButton(text: AppLocalizations.of(context)!.continueShopping, onPressed: () => context.go(Routes.home))),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline_rounded, size: 72, color: AppColors.gold),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.loginRequired, style: AppTypography.titleLarge),
          const SizedBox(height: 24),
          SizedBox(width: 200, child: AppButton(text: AppLocalizations.of(context)!.login, onPressed: () => context.push(Routes.login))),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.errorPrefix(error), style: AppTypography.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          AppButton(text: AppLocalizations.of(context)!.retry, onPressed: onRetry),
        ],
      ),
    );
  }
}

class _CheckoutShimmer extends StatelessWidget {
  const _CheckoutShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmer(width: 120, height: 20),
          const SizedBox(height: 12),
          const AppShimmer(width: double.infinity, height: 120, borderRadius: 20),
          const SizedBox(height: 24),
          const AppShimmer(width: 120, height: 20),
          const SizedBox(height: 12),
          const AppShimmer(width: double.infinity, height: 150, borderRadius: 20),
          const SizedBox(height: 24),
          const AppShimmer(width: 120, height: 20),
          const SizedBox(height: 12),
          const AppShimmer(width: double.infinity, height: 120, borderRadius: 20),
        ],
      ),
    );
  }
}
