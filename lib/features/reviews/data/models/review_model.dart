import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review_entity.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromFirestore(Map<String, dynamic> data, {String? id}) {
    final timestamp = (data['createdAt'] as Timestamp?) ?? (data['date'] as Timestamp?);
    return ReviewModel(
      id: id ?? data['id'] ?? '',
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      comment: data['comment'] ?? '',
      date: timestamp?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'productId': productId,
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'createdAt': Timestamp.fromDate(date),
  };

  ReviewEntity toEntity() => ReviewEntity(
    id: id,
    productId: productId,
    userId: userId,
    userName: userName,
    rating: rating,
    comment: comment,
    date: date,
  );
}
