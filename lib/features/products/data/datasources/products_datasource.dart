import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductsDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products => _firestore.collection('products');

  Future<List<ProductModel>> getProducts({int limit = 20, String? startAfterId}) async {
    Query<Map<String, dynamic>> query = _products.orderBy('createdAt', descending: true).limit(limit);
    if (startAfterId != null) {
      final doc = await _products.doc(startAfterId).get();
      if (doc.exists) query = query.startAfterDocument(doc);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((d) => ProductModel.fromFirestore(d.data(), id: d.id)).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId, {String? startAfterId, int limit = 11}) async {
    // No orderBy to avoid composite index requirement — sorted client-side instead.
    Query<Map<String, dynamic>> query = _products
        .where('categoryId', isEqualTo: categoryId)
        .limit(limit);
    if (startAfterId != null) {
      final doc = await _products.doc(startAfterId).get();
      if (doc.exists) query = query.startAfterDocument(doc);
    }
    final snapshot = await query.get();
    final results = snapshot.docs.map((d) => ProductModel.fromFirestore(d.data(), id: d.id)).toList();
    // Sort by createdAt descending in memory
    results.sort((a, b) {
      final aTime = a.createdAt ?? DateTime(2000);
      final bTime = b.createdAt ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return results;
  }

  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await _products.where('isFeatured', isEqualTo: true).limit(6).get();
      return snapshot.docs.map((d) => ProductModel.fromFirestore(d.data(), id: d.id)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductModel>> getNewProducts() async {
    try {
      final snapshot = await _products.where('isNew', isEqualTo: true).limit(6).get();
      return snapshot.docs.map((d) => ProductModel.fromFirestore(d.data(), id: d.id)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductModel>> getBestSellerProducts() async {
    try {
      final snapshot = await _products.where('isBestSeller', isEqualTo: true).limit(6).get();
      return snapshot.docs.map((d) => ProductModel.fromFirestore(d.data(), id: d.id)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ProductModel> getProductById(String id) async {
    final doc = await _products.doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null) throw Exception('المنتج غير موجود');
    return ProductModel.fromFirestore(data, id: doc.id);
  }

  /// Search products using Firestore arrayContains on searchKeywords.
  Future<List<ProductModel>> searchProducts(
    String query, {
    String? startAfterId,
    int limit = 20,
  }  ) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    Query<Map<String, dynamic>> searchQuery = _products
        .where('searchKeywords', arrayContains: q)
        .limit(limit);

    if (startAfterId != null) {
      final cursorDoc = await _products.doc(startAfterId).get();
      if (cursorDoc.exists) {
        searchQuery = searchQuery.startAfterDocument(cursorDoc);
      }
    }

    final snapshot = await searchQuery.get();
    return snapshot.docs.map((d) => ProductModel.fromFirestore(d.data(), id: d.id)).toList();
  }

  Future<List<ProductModel>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    // Firestore whereIn supports up to 10 elements
    List<ProductModel> products = [];
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final snapshot = await _products.where(FieldPath.documentId, whereIn: chunk).get();
      products.addAll(
        snapshot.docs.map((d) => ProductModel.fromFirestore(d.data(), id: d.id)),
      );
    }
    return products;
  }
}
