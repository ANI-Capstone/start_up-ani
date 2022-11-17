import 'package:ani_capstone/models/post.dart';

class Product {
  Post post;
  int? quantity;

  Product({required this.post, this.quantity});

  static Product fromJson(Map<String, dynamic> json, String productId) =>
      Product(
          post: Post.fromJson(json['post'], productId),
          quantity: json['quantity']);

  Map<String, dynamic> toJson() =>
      {'post': post.toJson(), 'quantitiy': quantity};
}
