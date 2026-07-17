import 'package:flutter_test/flutter_test.dart';
import 'package:elct/features/reviews/domain/entities/review_entity.dart';

void main() {
  group('ReviewEntity', () {
    test('creates with all required fields', () {
      final review = ReviewEntity(
        id: 'r1',
        productId: 'p1',
        userId: 'u1',
        userName: 'User',
        rating: 4.5,
        comment: 'Great!',
        date: DateTime(2025, 1, 1),
      );
      expect(review.id, 'r1');
      expect(review.rating, 4.5);
    });
  });
}
