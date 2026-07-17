class OrderItemEntity {
  final String productId;
  final String nameAr;
  final String nameEn;
  final String image;
  final double price;
  final int quantity;
  final Map<String, String>? selectedOptions;

  const OrderItemEntity({
    required this.productId,
    required this.nameAr,
    required this.nameEn,
    required this.image,
    required this.price,
    required this.quantity,
    this.selectedOptions,
  });

  double get total => price * quantity;
}

class ShippingAddressEntity {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String? label;
  final double? latitude;
  final double? longitude;

  const ShippingAddressEntity({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    this.label,
    this.latitude,
    this.longitude,
  });
}

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class OrderEntity {
  final String id;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double shipping;
  final double total;
  final OrderStatus status;
  final ShippingAddressEntity shippingAddress;
  final String paymentMethod;
  final DateTime createdAt;
  final String deliveryType; // 'normal' or 'fast'
  final DateTime? deliveryDate;
  final String? deliveryTime;

  const OrderEntity({
    required this.id,
    required this.items,
    required this.subtotal,
    this.shipping = 0,
    required this.total,
    required this.status,
    required this.shippingAddress,
    this.paymentMethod = 'cod',
    required this.createdAt,
    this.deliveryType = 'normal',
    this.deliveryDate,
    this.deliveryTime,
  });
}
