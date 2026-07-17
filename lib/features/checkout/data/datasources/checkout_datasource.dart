import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/promo_code_model.dart';

class CheckoutDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrder(OrderModel order, {String? promoCode}) async {
    if (promoCode != null &&
        promoCode.isNotEmpty &&
        !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(promoCode)) {
      throw Exception('promoInvalid');
    }
    
    String numericOrderId = order.id;
    if (numericOrderId.isEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch.toString();
      final randomPart = Random().nextInt(9999).toString().padLeft(4, '0');
      // Last 4 digits of timestamp + 4 random digits = 8 digits total
      numericOrderId = '${now.substring(now.length - 4)}$randomPart';
    }
    
    final docRef = _firestore.collection('orders').doc(numericOrderId);

    await _firestore.runTransaction((transaction) async {
      // 1. Validate promo code if provided
      double discount = 0.0;
      PromoCodeModel? promo;
      DocumentReference<Map<String, dynamic>>? promoRef;
      if (promoCode != null && promoCode.isNotEmpty) {
        promoRef = _firestore.collection('promoCodes').doc(promoCode);
        final promoSnap = await transaction.get(promoRef);
        if (!promoSnap.exists) {
          throw Exception('promoNotFound');
        }
        final promoData = promoSnap.data();
        if (promoData == null) throw Exception('promoNotFound');
        promo = PromoCodeModel.fromFirestore(promoData);
        if (!promo.isValid) {
          throw Exception('promoExpiredOrUsed');
        }
      }

      final settingsSnap = await transaction.get(
        _firestore.collection('settings').doc('shipping'),
      );
      final settings = settingsSnap.data() ?? const <String, dynamic>{};
      final freeShippingThreshold =
          (settings['freeShippingThreshold'] as num? ?? 500).toDouble();
      final shippingCostValue = settings['shippingCost'] ?? settings['shippingFee'];
      final shippingCost = (shippingCostValue as num? ?? 30).toDouble();

      // 2. Read all product docs first
      final productRefs = order.items
          .map((item) => _firestore.collection('products').doc(item.productId))
          .toList();

      final productSnaps = await Future.wait(
        productRefs.map((ref) => transaction.get(ref)),
      );

      // 3. Validate stock for every item
      final canonicalItems = <OrderItemModel>[];
      var subtotal = 0.0;
      for (int i = 0; i < order.items.length; i++) {
        final item = order.items[i];
        final snap = productSnaps[i];
        final data = snap.data();
        if (!snap.exists) {
          throw Exception('المنتج ${item.nameAr} لم يعد متوفراً');
        }
        if (item.quantity <= 0) {
          throw Exception('كمية غير صالحة للمنتج: ${item.nameAr}');
        }
        final currentStock = (data?['stockQuantity'] as num? ?? 0).toInt();
        if (currentStock < item.quantity) {
          throw Exception('الكمية غير كافية للمنتج: ${item.nameAr}');
        }
        final currentPrice = (data?['price'] as num? ?? 0).toDouble();
        final currentNameAr = (data?['nameAr'] ?? item.nameAr).toString();
        final currentNameEn = (data?['nameEn'] ?? item.nameEn).toString();
        final currentImages = data?['images'];
        final currentImage = currentImages is List && currentImages.isNotEmpty
            ? currentImages.first.toString()
            : item.image;

        canonicalItems.add(
          OrderItemModel(
            productId: item.productId,
            nameAr: currentNameAr,
            nameEn: currentNameEn,
            image: currentImage,
            price: currentPrice,
            quantity: item.quantity,
            selectedOptions: item.selectedOptions,
          ),
        );
        subtotal += currentPrice * item.quantity;
      }

      if (promo != null) {
        discount = subtotal * (promo.discountPercent / 100);
        if (discount > subtotal) discount = subtotal;
      }

      final shipping = shippingCost <= 0 || freeShippingThreshold <= 0 || subtotal >= freeShippingThreshold
          ? 0.0
          : shippingCost;
      final total = (subtotal - discount) + shipping;

      // 4. Decrement stock for each item
      for (int i = 0; i < order.items.length; i++) {
        final item = order.items[i];
        transaction.update(productRefs[i], {
          'stockQuantity': FieldValue.increment(-item.quantity),
        });
      }

      if (promoRef != null) {
        transaction.update(promoRef, {'currentUses': FieldValue.increment(1)});
      }

      // 5. Create the order document
      final data = order.toFirestore();
      data['id'] = docRef.id;
      data['items'] = canonicalItems.map((item) => item.toFirestore()).toList();
      data['subtotal'] = subtotal;
      data['shipping'] = shipping;
      data['total'] = total;
      data['discount'] = discount;
      if (promoCode != null) {
        data['promoCode'] = promoCode;
      }
      transaction.set(docRef, data);
    });

    return docRef.id;
  }

  Future<PromoCodeModel?> validatePromoCode(String code) async {
    try {
      final doc = await _firestore.collection('promoCodes').doc(code).get();
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      final promo = PromoCodeModel.fromFirestore(data);
      if (!promo.isValid) return null;
      return promo;
    } catch (_) {
      return null;
    }
  }

  Future<OrderModel> getOrder(String orderId, String userId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    final data = doc.data();
    if (!doc.exists || data == null) throw Exception('الطلب غير موجود');
    final order = OrderModel.fromFirestore({...data, 'id': doc.id});
    if (order.userId != userId) throw Exception('Unauthorized');
    return order;
  }
}
