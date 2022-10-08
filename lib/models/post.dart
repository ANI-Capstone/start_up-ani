import 'package:ani_capstone/models/user.dart';

import '../utils.dart';

class Post {
  User publisher;
  DateTime postedAt;
  String name;
  String description;
  double price;
  String unit;
  String location;
  List<String> images;
  double? rating;
  int? rateCount;
  int? likes;

  Post(
      {required this.publisher,
      required this.postedAt,
      required this.name,
      required this.description,
      required this.price,
      required this.unit,
      required this.location,
      required this.images,
      this.rating = 0,
      this.rateCount = 0,
      this.likes = 0});

  static Post fromJson(Map<String, dynamic> json) => Post(
      publisher: User.fromJson(json['user']),
      postedAt: Utils.toDateTime(json['postedAt']),
      name: json['name'],
      description: json['description'],
      price: json['price'],
      unit: json['unit'],
      location: json['location'],
      images: json['images'],
      rating: json['rating'],
      rateCount: json['rateCount'],
      likes: json['likes']);

  Map<String, dynamic> toJson() => {
        'publisher': publisher.toJson(),
        'postedAt': Utils.fromDateTimeToJson(postedAt),
        'name': name,
        'description': description,
        'price': price,
        'unit': unit,
        'location': location,
        'images': images,
        'rating': rating,
        'rateCount': rateCount,
        'likes': likes
      };
}
