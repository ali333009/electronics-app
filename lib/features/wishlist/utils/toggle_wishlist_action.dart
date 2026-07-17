import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/core/widgets/app_toast.dart';
import 'package:elct/l10n/app_localizations.dart';
import 'package:elct/features/wishlist/presentation/providers/wishlist_provider.dart';

Future<void> toggleWishlistAction({
  required WidgetRef ref,
  required BuildContext context,
  required String userId,
  required String productId,
  required String nameAr,
  required String nameEn,
  required String image,
  required double price,
  double? originalPrice,
  int? discountPercent,
  required double rating,
  required int reviewCount,
  required int stockQuantity,
  required bool isInWishlist,
}) async {
  try {
    await ref.read(wishlistRepositoryProvider).toggleItem(
      userId: userId,
      productId: productId,
      nameAr: nameAr,
      nameEn: nameEn,
      image: image,
      price: price,
      originalPrice: originalPrice,
      discountPercent: discountPercent,
      rating: rating,
      reviewCount: reviewCount,
      stockQuantity: stockQuantity,
    );
    if (context.mounted) {
      AppToast.show(
        context,
        isInWishlist
            ? AppLocalizations.of(context)!.removeFromWishlist
            : AppLocalizations.of(context)!.addToWishlist,
        icon: isInWishlist ? Icons.favorite_border : Icons.favorite,
      );
    }
  } catch (e) {
    if (context.mounted) {
      AppToast.show(
        context,
        AppLocalizations.of(context)!.loadErrorPrefix(e.toString()),
        icon: Icons.error_outline,
      );
    }
  }
}
