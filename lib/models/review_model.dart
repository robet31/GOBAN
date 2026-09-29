import 'package:equatable/equatable.dart';

/// Review model — rating & comment for completed orders
class ReviewModel extends Equatable {
  final int? id;
  final String orderId;
  final String reviewerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  // Joined fields
  final String? reviewerName;
  final String? reviewerAvatar;

  const ReviewModel({
    this.id,
    required this.orderId,
    required this.reviewerId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.reviewerName,
    this.reviewerAvatar,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as int?,
      orderId: map['order_id'] as String,
      reviewerId: map['reviewer_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      reviewerName: map['reviewer_name'] as String?,
      reviewerAvatar: map['reviewer_avatar'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'reviewer_id': reviewerId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props =>
      [id, orderId, reviewerId, rating, comment, createdAt];
}
