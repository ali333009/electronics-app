import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:elct/features/checkout/data/models/order_model.dart';
import '../../../helpers/mock_datasources.dart';

void main() {
  group('OrdersRepositoryImpl', () {
    late MockOrdersDatasource mockDs;
    late OrdersRepositoryImpl repository;

    setUp(() {
      mockDs = MockOrdersDatasource();
      repository = OrdersRepositoryImpl(datasource: mockDs);
    });

    test('getUserOrders returns list of orders', () async {
      mockDs.orders = [
        OrderModel(id: 'o1', userId: 'u1', items: [], subtotal: 100, total: 100, shippingAddress: {}),
      ];
      final orders = await repository.getUserOrders('u1');
      expect(orders.length, 1);
    });

    test('getOrder returns single order', () async {
      mockDs.orders = [
        OrderModel(id: 'o1', userId: 'u1', items: [], subtotal: 100, total: 100, shippingAddress: {}),
      ];
      final order = await repository.getOrder('u1', 'o1');
      expect(order.id, 'o1');
    });
  });
}
