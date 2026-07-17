import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/i_orders_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final ordersRepositoryProvider = Provider<IOrdersRepository>((ref) {
  return OrdersRepositoryImpl();
});

final ordersListProvider = FutureProvider<List<OrderEntity>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(ordersRepositoryProvider).getUserOrders(userId);
});

final orderDetailProvider = FutureProvider.family<OrderEntity, String>((ref, orderId) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) throw Exception('Not authenticated');
  return ref.watch(ordersRepositoryProvider).getOrder(userId, orderId);
});
