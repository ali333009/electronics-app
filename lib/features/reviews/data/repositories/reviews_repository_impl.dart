import '../../domain/repositories/i_reviews_repository.dart';
import '../datasources/reviews_datasource.dart';
import '../models/review_model.dart';

class ReviewsRepositoryImpl implements IReviewsRepository {
  final ReviewsDatasource _datasource;

  ReviewsRepositoryImpl({ReviewsDatasource? datasource})
    : _datasource = datasource ?? ReviewsDatasource();

  @override
  Future<List<ReviewModel>> getReviews(String productId) =>
      _datasource.getReviews(productId);

  @override
  Future<void> addReview(ReviewModel review) =>
      _datasource.addReview(review);
}
