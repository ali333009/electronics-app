import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:elct/core/theme/app_colors.dart';
import 'package:elct/core/theme/app_typography.dart';
import 'package:elct/core/widgets/app_button.dart';
import 'package:elct/core/widgets/app_text_field.dart';
import 'package:elct/core/utils/price_formatter.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/core/models/currency.dart';
import 'package:elct/features/cart/domain/extensions/cart_item_entity_localization.dart';
import 'package:elct/features/cart/domain/entities/cart_item_entity.dart';
import 'package:elct/features/checkout/presentation/providers/checkout_controller.dart';

class CheckoutOrderSummary extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double grandTotal;
  final Currency currency;
  final List<CartItemEntity> items;
  final CheckoutController controller;
  final CheckoutState state;

  const CheckoutOrderSummary({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.grandTotal,
    required this.currency,
    required this.items,
    required this.controller,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(AppLocalizations.of(context)!.promoCode),
        const SizedBox(height: 10),
        _buildPromoCodeField(context),
        const SizedBox(height: 24),

        _buildCollapsibleItemsHeader(context, items.length),
        if (state.showItems) ...[
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, i) {
              return _buildOrderItem(context, items[i]);
            },
          ),
        ],
        const SizedBox(height: 24),

        _buildSectionHeader(AppLocalizations.of(context)!.costSummary),
        const SizedBox(height: 10),
        _buildOrderSummaryCard(context),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.labelLarge,
    );
  }

  Widget _buildPromoCodeField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller.promoController,
                  label: '',
                  hint: AppLocalizations.of(context)!.couponHint,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: AppButton(
                  text: state.appliedPromoCode != null ? AppLocalizations.of(context)!.applied : AppLocalizations.of(context)!.apply,
                  isLoading: state.isApplyingPromo,
                  onPressed: (state.appliedPromoCode != null || state.isApplyingPromo) ? null : () => controller.applyPromoCode(context, subtotal),
                ),
              ),
            ],
          ),
          if (state.appliedPromoCode != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.appliedPromoCode(state.appliedPromoCode ?? ''),
                  style: AppTypography.badge.copyWith(color: Colors.green),
                ),
                GestureDetector(
                  onTap: () {
                    controller.clearPromoCode();
                    HapticFeedback.lightImpact();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.cancelCode,
                    style: AppTypography.badge.copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapsibleItemsHeader(BuildContext context, int itemCount) {
    return InkWell(
      onTap: () {
        controller.toggleItems();
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.orderItems(itemCount.toString()),
              style: AppTypography.labelLarge,
            ),
            Row(
              children: [
                Text(
                  state.showItems ? AppLocalizations.of(context)!.hideDetails : AppLocalizations.of(context)!.showDetails,
                  style: AppTypography.caption,
                ),
                const SizedBox(width: 4),
                Icon(
                  state.showItems ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, CartItemEntity item) {
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: item.image,
                fit: BoxFit.contain,
                memCacheWidth: 100,
                memCacheHeight: 100,
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
                  style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppLocalizations.of(context)!.itemQuantity(item.quantity),
                  style: AppTypography.badge.copyWith(fontWeight: FontWeight.w400, color: AppColors.textSecondary),
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
            formatPrice(item.totalPrice, currency),
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _summaryRow(AppLocalizations.of(context)!.subtotal, formatPrice(subtotal, currency)),
          if (state.couponDiscount > 0) ...[
            const SizedBox(height: 10),
            _summaryRow(
              AppLocalizations.of(context)!.couponDiscount,
              '- ${formatPrice(state.couponDiscount, currency)}',
              valueColor: Colors.green,
            ),
          ],
          const SizedBox(height: 10),
          _summaryRow(
            AppLocalizations.of(context)!.shippingCost,
            shipping == 0 ? AppLocalizations.of(context)!.free : formatPrice(shipping, currency),
            valueColor: shipping == 0 ? Colors.green : AppColors.textPrimary,
          ),
          const Divider(height: 24, color: AppColors.border),
          _summaryRow(AppLocalizations.of(context)!.grandTotal, formatPrice(grandTotal, currency), isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal ? AppTypography.labelLarge : AppTypography.caption,
        ),
        Text(
          value,
          style: isTotal
              ? AppTypography.titleLarge.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)
              : AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textPrimary),
        ),
      ],
    );
  }
}
