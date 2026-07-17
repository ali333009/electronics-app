import '../entities/order_entity.dart';
import '../entities/promo_code_entity.dart';

abstract class ICheckoutRepository {
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
  });

  Future<PromoCodeEntity?> validatePromoCode(String code);
}
