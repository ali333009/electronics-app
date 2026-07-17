import '../../domain/entities/order_entity.dart';
import '../../domain/entities/promo_code_entity.dart';
import '../../domain/repositories/i_checkout_repository.dart';
import '../datasources/checkout_datasource.dart';
import '../../../cart/data/datasources/cart_datasource.dart';
import '../models/order_model.dart';

class CheckoutRepositoryImpl implements ICheckoutRepository {
  final CheckoutDatasource _datasource;

  CheckoutRepositoryImpl({CheckoutDatasource? datasource})
    : _datasource = datasource ?? CheckoutDatasource();

  @override
  Future<OrderEntity> placeOrder({
    required String orderId,
    required String userId,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double shipping,
    required double total,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    String? promoCode,
    String deliveryType = 'normal',
    String? deliveryDate,
    String? deliveryTime,
  }) async {
    final model = OrderModel(
      id: orderId,
      userId: userId,
      items: items.map((e) => OrderItemModel.fromFirestore(e)).toList(),
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      status: 'ordered',
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      deliveryType: deliveryType,
      deliveryDate: deliveryDate,
      deliveryTime: deliveryTime,
    );

    await _datasource.createOrder(model, promoCode: promoCode);
    
    try {
      await CartDatasource().clearCart(userId);
    } catch (_) {
      // Best effort clear cart, failure shouldn't prevent order success return
    }

    final saved = await _datasource.getOrder(orderId, userId);
    return saved.toEntity();
  }

  @override
  Future<PromoCodeEntity?> validatePromoCode(String code) async {
    final promo = await _datasource.validatePromoCode(code);
    return promo?.toEntity();
  }
}
