import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/i_orders_repository.dart';
import '../datasources/orders_datasource.dart';

class OrdersRepositoryImpl implements IOrdersRepository {
  final OrdersDatasource _datasource;

  OrdersRepositoryImpl({OrdersDatasource? datasource})
    : _datasource = datasource ?? OrdersDatasource();

  @override
  Stream<List<OrderEntity>> watchOrders(String userId) {
    return _datasource.watchOrders(userId).map(
        (models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<List<OrderEntity>> getUserOrders(String userId) async {
    final models = await _datasource.getUserOrders(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<OrderEntity> getOrder(String userId, String orderId) async {
    final model = await _datasource.getOrder(orderId, userId);
    return model.toEntity();
  }
}
