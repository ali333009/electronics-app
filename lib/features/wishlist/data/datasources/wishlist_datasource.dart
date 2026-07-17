import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist_item_model.dart';

class WishlistDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _wishlistRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('wishlist');

  Stream<List<WishlistItemModel>> watchWishlist(String userId) {
    return _wishlistRef(userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                WishlistItemModel.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addItem(WishlistItemModel item) async {
    await _wishlistRef(item.userId).doc(item.id).set(item.toFirestore());
  }

  Future<void> removeItem(String userId, String productId) async {
    await _wishlistRef(userId).doc(productId).delete();
  }

  Future<bool> isInWishlist(String userId, String productId) async {
    try {
      final doc = await _wishlistRef(userId).doc(productId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
