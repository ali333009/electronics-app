import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elct/features/reviews/data/models/review_model.dart';
import 'package:elct/features/reviews/domain/entities/review_entity.dart';

Map<String, dynamic> fullReviewData() => {
  'productId': 'prod-1',
  'userId': 'user-1',
  'userName': 'Test User',
  'rating': 4.5,
  'comment': 'Great product!',
  'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
};

void main() {
  group('ReviewModel fromFirestore', () {
    test('parses full data correctly', () {
      final model = ReviewModel.fromFirestore(fullReviewData(), id: 'rev-1');
      expect(model.id, 'rev-1');
      expect(model.rating, 4.5);
      expect(model.userName, 'Test User');
    });

    test('handles missing fields with defaults', () {
      final model = ReviewModel.fromFirestore({});
      expect(model.rating, 0.0);
      expect(model.comment, '');
    });
  });

  group('ReviewModel toEntity', () {
    test('converts to ReviewEntity', () {
      final model = ReviewModel.fromFirestore(fullReviewData(), id: 'rev-1');
      final entity = model.toEntity();
      expect(entity, isA<ReviewEntity>());
      expect(entity.rating, 4.5);
    });
  });
}
