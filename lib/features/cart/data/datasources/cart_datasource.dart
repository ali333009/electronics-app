import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

class CartDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _cartRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('cart');

  Stream<List<CartItemModel>> watchCart(String userId) {
    return _cartRef(userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartItemModel.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addItem(CartItemModel item) async {
    await _cartRef(item.userId).doc(item.id).set(item.toFirestore());
  }

  Future<void> updateQuantity(String userId, String itemId, int quantity) async {
    await _cartRef(userId).doc(itemId).update({'quantity': quantity});
  }

  Future<void> updateOptions(String userId, String itemId, Map<String, String> selectedOptions) async {
    await _cartRef(userId).doc(itemId).update({'selectedOptions': selectedOptions});
  }

  Future<void> removeItem(String userId, String itemId) async {
    await _cartRef(userId).doc(itemId).delete();
  }

  Future<void> clearCart(String userId) async {
    final snapshot = await _cartRef(userId).get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> mergeGuestCart(String userId, List<CartItemModel> items) async {
    if (items.isEmpty) return;
    final snapshot = await _cartRef(userId).get();
    final existingItems = {
      for (final doc in snapshot.docs)
        doc.id: CartItemModel.fromFirestore(doc.data() as Map<String, dynamic>)
    };
    
    final batch = _firestore.batch();
    for (final item in items) {
      final ref = _cartRef(userId).doc(item.id);
      final existing = existingItems[item.id];
      if (existing != null) {
        final newQuantity = (existing.quantity + item.quantity).clamp(1, existing.stockQuantity).toInt();
        batch.update(ref, {'quantity': newQuantity});
      } else {
        batch.set(ref, item.toFirestore());
      }
    }
    await batch.commit();
  }

  Future<CartItemModel?> getItemByProductId(String userId, String productId) async {
    final doc = await _cartRef(userId).doc(productId).get();
    if (!doc.exists) return null;
    return CartItemModel.fromFirestore(doc.data() as Map<String, dynamic>);
  }
}
