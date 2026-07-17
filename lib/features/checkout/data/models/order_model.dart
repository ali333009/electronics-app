import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/order_entity.dart';

class OrderItemModel {
  final String productId;
  final String nameAr;
  final String nameEn;
  final String image;
  final double price;
  final int quantity;
  final Map<String, String>? selectedOptions;

  const OrderItemModel({
    required this.productId,
    required this.nameAr,
    required this.nameEn,
    required this.image,
    required this.price,
    required this.quantity,
    this.selectedOptions,
  });

  factory OrderItemModel.fromFirestore(Map<String, dynamic> data) {
    return OrderItemModel(
      productId: data['productId'] ?? '',
      nameAr: data['nameAr'] ?? '',
      nameEn: data['nameEn'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      selectedOptions: _parseSelectedOptions(data),
    );
  }

  static Map<String, String>? _parseSelectedOptions(Map<String, dynamic> data) {
    if (data['selectedOptions'] is Map) {
      final map = data['selectedOptions'] as Map;
      return map.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    final result = <String, String>{};
    if (data['selectedColor'] != null) result['اللون'] = data['selectedColor'].toString();
    if (data['selectedSize'] != null) result['المقاس'] = data['selectedSize'].toString();
    return result.isEmpty ? null : result;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'image': image,
      'price': price,
      'quantity': quantity,
      'selectedOptions': selectedOptions,
    };
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      productId: productId,
      nameAr: nameAr,
      nameEn: nameEn,
      image: image,
      price: price,
      quantity: quantity,
      selectedOptions: selectedOptions,
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double shipping;
  final double total;
  final String status;
  final Map<String, dynamic> shippingAddress;
  final String paymentMethod;
  final double discount;
  final String? promoCode;
  final String deliveryType;
  final String? deliveryDate;
  final String? deliveryTime;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.shipping = 0,
    required this.total,
    this.status = 'ordered',
    required this.shippingAddress,
    this.paymentMethod = 'cod',
    this.discount = 0,
    this.promoCode,
    this.deliveryType = 'normal',
    this.deliveryDate,
    this.deliveryTime,
    this.createdAt,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data) {
    return OrderModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      items: (data['items'] as List?)
              ?.map((e) => OrderItemModel.fromFirestore(e as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      shipping: (data['shipping'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'ordered',
      shippingAddress:
          (data['shippingAddress'] as Map<String, dynamic>?) ?? {},
      paymentMethod: data['paymentMethod'] ?? 'cod',
      discount: (data['discount'] ?? 0).toDouble(),
      promoCode: data['promoCode'],
      deliveryType: data['deliveryType'] ?? 'normal',
      deliveryDate: data['deliveryDate'],
      deliveryTime: data['deliveryTime'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((e) => e.toFirestore()).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'total': total,
      'status': status,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'deliveryType': deliveryType,
      'deliveryDate': deliveryDate,
      'deliveryTime': deliveryTime,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      items: items.map((e) => e.toEntity()).toList(),
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      status: _parseStatus(status),
      shippingAddress: ShippingAddressEntity(
        name: shippingAddress['name'] ?? '',
        phone: shippingAddress['phone'] ?? '',
        address: shippingAddress['address'] ?? '',
        city: shippingAddress['city'] ?? '',
        label: shippingAddress['label'],
        latitude: (shippingAddress['latitude'] as num?)?.toDouble(),
        longitude: (shippingAddress['longitude'] as num?)?.toDouble(),
      ),
      paymentMethod: paymentMethod,
      createdAt: createdAt ?? DateTime.now(),
      deliveryType: deliveryType,
      deliveryTime: deliveryTime,
    );
  }

  OrderStatus _parseStatus(String s) {
    switch (s.toLowerCase().trim()) {
      case 'pending':
      case 'confirmed':
      case 'processing':
      case 'active':
        return OrderStatus.confirmed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      case 'ordered':
      default:
        return OrderStatus.pending;
    }
  }
}
