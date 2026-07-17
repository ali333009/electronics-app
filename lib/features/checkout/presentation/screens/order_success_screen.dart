import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/models/currency.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../domain/entities/order_entity.dart';
import 'package:elct/l10n/app_localizations.dart';

class OrderSuccessScreen extends ConsumerWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);

    if (orderId.isEmpty) {
      return _errorView(context, l10n.orderNotFound);
    }

    final orderAsync = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: orderAsync.when(
          loading: () => const CircularProgressIndicator(color: AppColors.gold),
          error: (err, _) => _errorView(
            context,
            '${l10n.orderNotFound}\n${l10n.orderNumber(orderId)}',
          ),
          data: (order) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSuccessIcon(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.orderSuccess, style: AppTypography.displayMedium),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.orderNumber(orderId.toUpperCase()),
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildOrderSummary(context, l10n, order, currency),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    text: l10n.trackOrder,
                    onPressed: () {
                      context.go(Routes.home);
                      context.push('${Routes.orders}/$orderId');
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    text: l10n.backToHome,
                    isOutlined: true,
                    onPressed: () => context.go(Routes.home),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_outline,
        size: 56,
        color: AppColors.success,
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).fadeIn();
  }

  Widget _buildOrderSummary(
    BuildContext context,
    AppLocalizations l10n,
    order,
    Currency currency,
  ) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.orderSummary, style: AppTypography.titleLarge),
              const Divider(color: AppColors.gold, height: AppSpacing.lg),
              _summaryRow(
                l10n.orderItems(order.items.length),
                formatPrice(order.total, currency),
              ),
              const SizedBox(height: AppSpacing.sm),
              _summaryRow(
                l10n.paymentMethod,
                _paymentMethodLabel(l10n, order.paymentMethod),
              ),
              const SizedBox(height: AppSpacing.sm),
              _summaryRow(l10n.orderStatus, _statusLabel(l10n, order.status)),
              const SizedBox(height: AppSpacing.sm),
              _summaryRow(
                l10n.orderPlaced,
                DateFormatter.dateTime(order.createdAt),
              ),
            ],
          ),
        )
        .animate()
        .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn();
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _errorView(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTypography.bodyLarge),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: l10n.backToHome,
              onPressed: () => context.go(Routes.home),
            ),
          ],
        ),
      ),
    );
  }

  String _paymentMethodLabel(AppLocalizations l10n, String method) {
    switch (method) {
      case 'card':
        return l10n.creditCard;
      case 'wallet':
        return l10n.digitalWallet;
      default:
        return l10n.cashOnDelivery;
    }
  }

  String _statusLabel(AppLocalizations l10n, OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return l10n.orderStatusPending;
      case OrderStatus.confirmed:
        return l10n.orderStatusConfirmed;
      case OrderStatus.shipped:
        return l10n.orderStatusShipped;
      case OrderStatus.delivered:
        return l10n.orderStatusDelivered;
      case OrderStatus.cancelled:
        return l10n.orderStatusCancelled;
    }
  }
}
