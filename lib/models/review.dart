import 'package:ani_capstone/models/user.dart';

import '../utils.dart';

class Review {
  String? reviewId;
  User reviewer;
  String productId;
  double rating;
  String? description;
  List<String>? photos;
  DateTime postedAt;

  Review(
      {this.reviewId,
      required this.reviewer,
      required this.productId,
      required this.rating,
      this.description,
      this.photos,
      required this.postedAt});

  static Review fromJson(Map<String, dynamic> json, String reviewId) => Review(
      reviewId: reviewId,
      reviewer: User.fromJson(json['reviewer']),
      productId: json['productId'],
      rating: json['rating'],
      description: json['description'],
      photos: List.from(json['photos']),
      postedAt: Utils.toDateTime(json['postedAt']));

  Map<String, dynamic> toJson() => {
        'reviewer': reviewer.toJson(),
        'productId': productId,
        'rating': rating,
        'photos': photos,
        'description': description,
        'postedAt': Utils.fromDateTimeToJson(postedAt)
      };
}
