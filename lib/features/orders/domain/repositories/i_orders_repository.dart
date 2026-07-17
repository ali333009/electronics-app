import 'dart:async';

import '../entities/order_entity.dart';

abstract class IOrdersRepository {
  Stream<List<OrderEntity>> watchOrders(String userId);
  Future<List<OrderEntity>> getUserOrders(String userId);
  Future<OrderEntity> getOrder(String userId, String orderId);
}
