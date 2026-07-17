import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/core/widgets/app_toast.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/features/auth/presentation/providers/auth_provider.dart';
import 'package:elct/features/cart/domain/entities/cart_item_entity.dart';
import 'package:elct/features/cart/presentation/providers/cart_provider.dart';
import 'package:elct/features/cart/presentation/providers/guest_cart_provider.dart';

Future<bool> addToCartAction({
  required WidgetRef ref,
  required BuildContext context,
  required String productId,
  required String nameAr,
  required String nameEn,
  required String image,
  required double price,
  double? originalPrice,
  int? discountPercent,
  required int stockQuantity,
  int quantity = 1,
  Map<String, String>? selectedOptions,
  VoidCallback? onSuccess,
  String Function(BuildContext context)? successMessageBuilder,
  bool showToast = true,
}) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) {
    ref.read(guestCartProvider.notifier).addItem(
      CartItemEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        nameAr: nameAr,
        nameEn: nameEn,
        image: image,
        price: price,
        originalPrice: originalPrice,
        discountPercent: discountPercent,
        quantity: quantity,
        stockQuantity: stockQuantity,
        isAvailable: stockQuantity > 0,
        selectedOptions: selectedOptions,
      ),
    );
    if (showToast && context.mounted) {
      final msg = successMessageBuilder?.call(context) ??
          AppLocalizations.of(context)!.addedToCartToast;
      AppToast.show(context, msg, icon: Icons.check_circle);
    }
    onSuccess?.call();
    return true;
  }
  try {
    await ref.read(cartRepositoryProvider).addItem(
      userId: userId,
      productId: productId,
      nameAr: nameAr,
      nameEn: nameEn,
      image: image,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      quantity: quantity,
      stockQuantity: stockQuantity,
      selectedOptions: selectedOptions,
    );
    if (showToast && context.mounted) {
      final msg = successMessageBuilder?.call(context) ??
          AppLocalizations.of(context)!.addedToCartToast;
      AppToast.show(context, msg, icon: Icons.check_circle);
    }
    onSuccess?.call();
    return true;
  } catch (e) {
    if (context.mounted) {
      AppToast.show(
        context,
        AppLocalizations.of(context)!.loadErrorPrefix(e.toString()),
        icon: Icons.error_outline,
      );
    }
    return false;
  }
}
