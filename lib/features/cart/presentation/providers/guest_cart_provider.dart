import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/i_cart_repository.dart';

class GuestCartNotifier extends StateNotifier<List<CartItemEntity>> {
  GuestCartNotifier() : super([]);

  bool _isSameItem(CartItemEntity a, CartItemEntity b) {
    if (a.productId != b.productId) return false;
    final optsA = a.selectedOptions ?? {};
    final optsB = b.selectedOptions ?? {};
    if (optsA.length != optsB.length) return false;
    for (final key in optsA.keys) {
      if (optsA[key] != optsB[key]) return false;
    }
    return true;
  }

  void addItem(CartItemEntity item) {
    if (item.stockQuantity <= 0) return;
    final idx = state.indexWhere((i) => _isSameItem(i, item));
    if (idx >= 0) {
      final existing = state[idx];
      final newQuantity =
          (existing.quantity + item.quantity).clamp(1, existing.stockQuantity).toInt();
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == idx)
            CartItemEntity(
              id: existing.id,
              productId: existing.productId,
              nameAr: existing.nameAr,
              nameEn: existing.nameEn,
              image: existing.image,
              price: existing.price,
              originalPrice: existing.originalPrice,
              discountPercent: existing.discountPercent,
              quantity: newQuantity,
              stockQuantity: existing.stockQuantity,
              isAvailable: existing.isAvailable,
              selectedOptions: existing.selectedOptions,
            )
          else
            state[i],
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String id) {
    state = state.where((i) => i.id != id).toList();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeItem(id);
      return;
    }
    state = state.map((i) {
      if (i.id != id) return i;
      final newQuantity = quantity.clamp(1, i.stockQuantity).toInt();
      return CartItemEntity(
        id: i.id,
        productId: i.productId,
        nameAr: i.nameAr,
        nameEn: i.nameEn,
        image: i.image,
        price: i.price,
        originalPrice: i.originalPrice,
        discountPercent: i.discountPercent,
        quantity: newQuantity,
        stockQuantity: i.stockQuantity,
        isAvailable: i.isAvailable,
        selectedOptions: i.selectedOptions,
      );
    }).toList();
  }

  void clear() => state = [];

  Future<void> mergeToFirestore(ICartRepository repo, String userId) async {
    if (state.isEmpty) return;
    await repo.mergeGuestCart(userId, state);
    clear();
  }
}

final guestCartProvider =
    StateNotifierProvider<GuestCartNotifier, List<CartItemEntity>>((ref) {
  return GuestCartNotifier();
});
