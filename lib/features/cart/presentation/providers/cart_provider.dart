import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/i_cart_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'guest_cart_provider.dart';

final cartRepositoryProvider = Provider<ICartRepository>((ref) {
  return CartRepositoryImpl();
});

final _firestoreCartProvider = StreamProvider.family<List<CartItemEntity>, String>((ref, userId) {
  return ref.watch(cartRepositoryProvider).watchCart(userId);
});

final cartItemsProvider = Provider<AsyncValue<List<CartItemEntity>>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    final items = ref.watch(guestCartProvider);
    return AsyncValue.data(items);
  }
  return ref.watch(_firestoreCartProvider(userId));
});

final cartTotalProvider = Provider.autoDispose<double>((ref) {
  final cartAsync = ref.watch(cartItemsProvider);
  final items = cartAsync.valueOrNull ?? [];
  return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
});

final cartCountProvider = Provider.autoDispose<int>((ref) {
  final cartAsync = ref.watch(cartItemsProvider);
  final items = cartAsync.valueOrNull ?? [];
  return items.fold<int>(0, (sum, item) => sum + item.quantity);
});
