import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/reviews_repository_impl.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/i_reviews_repository.dart';

final reviewsRepositoryProvider = Provider<IReviewsRepository>((ref) {
  return ReviewsRepositoryImpl();
});

final reviewsProvider = FutureProvider.family<List<ReviewEntity>, String>((ref, productId) async {
  final repo = ref.read(reviewsRepositoryProvider);
  final models = await repo.getReviews(productId);
  return models.map((m) => m.toEntity()).toList();
});


