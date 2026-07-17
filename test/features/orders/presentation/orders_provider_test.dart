import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elct/features/orders/domain/repositories/i_orders_repository.dart';
import 'package:elct/features/orders/presentation/providers/orders_provider.dart';
import 'package:elct/features/checkout/domain/entities/order_entity.dart' as checkout;
import 'package:elct/features/auth/presentation/providers/auth_provider.dart';

class MockOrdersRepo implements IOrdersRepository {
  final List<checkout.OrderEntity> orders;

  MockOrdersRepo(this.orders);

  @override
  Stream<List<checkout.OrderEntity>> watchOrders(String userId) => Stream.value(orders);

  @override
  Future<List<checkout.OrderEntity>> getUserOrders(String userId) async => orders;

  @override
  Future<checkout.OrderEntity> getOrder(String userId, String orderId) async => orders.first;
}

final mockUserIdProvider = Provider<String?>((ref) => 'user-1');
final mockOrdersRepoProvider = Provider<IOrdersRepository>((ref) => MockOrdersRepo([]));

void main() {
  group('ordersListProvider', () {
    test('returns empty list when no orders', () async {
      final container = ProviderContainer(overrides: [
        currentUserIdProvider.overrideWith((ref) => 'user-1'),
        ordersRepositoryProvider.overrideWith((ref) => MockOrdersRepo([])),
      ]);
      addTearDown(() => container.dispose());
      final orders = await container.read(ordersListProvider.future);
      expect(orders, []);
    });
  });
}
