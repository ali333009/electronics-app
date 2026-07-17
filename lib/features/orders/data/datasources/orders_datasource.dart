import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../checkout/data/models/order_model.dart';

class OrdersDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OrderModel>> watchOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return OrderModel.fromFirestore({...data, 'id': doc.id});
            }).toList());
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return OrderModel.fromFirestore({...data, 'id': doc.id});
    }).toList();
  }

  Future<OrderModel> getOrder(String orderId, String userId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    final data = doc.data();
    if (!doc.exists || data == null) throw Exception('Order not found');
    final order = OrderModel.fromFirestore({...data, 'id': doc.id});
    if (order.userId != userId) throw Exception('Unauthorized');
    return order;
  }
}
