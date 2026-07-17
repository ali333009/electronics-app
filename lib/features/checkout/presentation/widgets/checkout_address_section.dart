import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:elct/core/theme/app_colors.dart';
import 'package:elct/core/theme/app_typography.dart';
import 'package:elct/core/widgets/app_button.dart';
import 'package:elct/core/widgets/app_text_field.dart';
import 'package:elct/core/router/routes.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/features/profile/domain/entities/address_entity.dart';
import 'package:elct/features/checkout/presentation/providers/checkout_controller.dart';

class CheckoutAddressSection extends StatelessWidget {
  final AddressEntity? address;
  final CheckoutController controller;
  final CheckoutState state;

  const CheckoutAddressSection({
    super.key,
    required this.address,
    required this.controller,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          context,
          AppLocalizations.of(context)!.deliveryAddress,
          actionLabel: AppLocalizations.of(context)!.editAddressLabel,
          onActionTap: () => context.push(Routes.addresses),
        ),
        const SizedBox(height: 10),
        _buildDeliveryAddressCard(context, address),
        const SizedBox(height: 24),

        _buildSectionHeader(context, AppLocalizations.of(context)!.contactDetails),
        const SizedBox(height: 10),
        _buildContactDetailsFields(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {String? actionLabel, VoidCallback? onActionTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge,
        ),
        if (actionLabel != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionLabel,
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.gold),
            ),
          ),
      ],
    );
  }

  Widget _buildDeliveryAddressCard(BuildContext context, AddressEntity? selected) {
    if (selected != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.gold, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected.city,
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selected.street,
                    style: AppTypography.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_off_outlined, color: AppColors.textMuted, size: 36),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.noAddress,
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            child: AppButton(
              text: AppLocalizations.of(context)!.addAddress,
              onPressed: () => context.push(Routes.addresses),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetailsFields(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          AppTextField(
            controller: controller.nameController,
            label: AppLocalizations.of(context)!.fullName,
            hint: AppLocalizations.of(context)!.nameHint,
            errorText: state.nameError,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: controller.phoneController,
            label: AppLocalizations.of(context)!.phoneNumber,
            hint: '01xxxxxxxxx',
            keyboardType: TextInputType.phone,
            errorText: state.phoneError,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
          ),
        ],
      ),
    );
  }
}
