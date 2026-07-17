import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/i_wishlist_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final wishlistRepositoryProvider = Provider<IWishlistRepository>((ref) {
  return WishlistRepositoryImpl();
});

final wishlistItemsProvider = StreamProvider<List<WishlistItemEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(wishlistRepositoryProvider).watchWishlist(userId);
});

final wishlistCountProvider = Provider.autoDispose<int>((ref) {
  final wishlistAsync = ref.watch(wishlistItemsProvider);
  return wishlistAsync.valueOrNull?.length ?? 0;
});
