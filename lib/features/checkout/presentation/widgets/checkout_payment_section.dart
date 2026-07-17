import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elct/core/theme/app_colors.dart';
import 'package:elct/core/theme/app_typography.dart';
import 'package:elct/core/enums/payment_method.dart';
import 'package:elct/core/widgets/app_toast.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/features/checkout/presentation/providers/checkout_controller.dart';

class CheckoutPaymentSection extends StatelessWidget {
  final CheckoutController controller;
  final CheckoutState state;

  const CheckoutPaymentSection({
    super.key,
    required this.controller,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.paymentMethod,
          style: AppTypography.labelLarge,
        ),
        const SizedBox(height: 10),
        ...PaymentMethod.values.map((method) => _buildPaymentCard(context, method)),
      ],
    );
  }

  Widget _buildPaymentCard(BuildContext context, PaymentMethod method) {
    final isSelected = state.selectedPayment == method;
    return GestureDetector(
      onTap: method.isComingSoon
          ? () {
              HapticFeedback.lightImpact();
              AppToast.show(context, AppLocalizations.of(context)!.checkoutUnavailable, icon: Icons.warning_amber_rounded);
            }
          : () {
              controller.setPaymentMethod(method);
              HapticFeedback.lightImpact();
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.gold : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 14),
            Icon(
              method.icon,
              color: isSelected ? AppColors.gold : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method.label(context),
                        style: AppTypography.labelLarge,
                      ),
                      if (method.isComingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.comingSoon,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.subtitle(context),
                    style: AppTypography.badge.copyWith(fontWeight: FontWeight.w400, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
