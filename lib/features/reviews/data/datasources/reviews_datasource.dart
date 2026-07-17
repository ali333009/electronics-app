import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewsDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _reviewsRef(String productId) =>
      _firestore.collection('products').doc(productId).collection('reviews');

  Future<List<ReviewModel>> getReviews(String productId) async {
    final snapshot = await _reviewsRef(productId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
    return snapshot.docs
        .map((d) => ReviewModel.fromFirestore(d.data() as Map<String, dynamic>, id: d.id))
        .toList();
  }

  Future<void> addReview(ReviewModel review) async {
    // 1. Save the review
    final docRef = _reviewsRef(review.productId).doc();
    await docRef.set({
      ...review.toFirestore(),
      'id': docRef.id,
    });

    // 2. Recalculate average rating from ALL reviews
    final allReviews = await _reviewsRef(review.productId).get();
    if (allReviews.docs.isEmpty) return;

    double totalRating = 0;
    for (final doc in allReviews.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalRating += (data['rating'] as num? ?? 0).toDouble();
    }
    final avgRating = totalRating / allReviews.docs.length;

    // 3. Update the product document with real avg rating and review count
    await _firestore.collection('products').doc(review.productId).update({
      'rating': double.parse(avgRating.toStringAsFixed(1)),
      'reviewCount': allReviews.docs.length,
    });
  }
}

