import '../../data/models/review_model.dart';

abstract class IReviewsRepository {
  Future<List<ReviewModel>> getReviews(String productId);
  Future<void> addReview(ReviewModel review);
}
