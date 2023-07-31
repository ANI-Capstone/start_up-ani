import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user.dart';

class Orders {
  String? orderId;
  User publisher;
  User costumer;
  List<Product> products;
  int totalPrice;
  int status;
  double? rating;

  Orders(
      {required this.publisher,
      required this.costumer,
      required this.products,
      required this.totalPrice,
      required this.status,
      this.orderId,
      this.rating});

  static Orders fromJson(Map<String, dynamic> json, String orderId) => Orders(
      orderId: orderId,
      publisher: User.fromJson(json['publisher']),
      costumer: User.fromJson(json['costumer']),
      products: List<Product>.from((json['products'] as Iterable)
          .map((product) => Product.fromJson(product))
          .toList()),
      totalPrice: json['totalPrice'],
      status: json['status'],
      rating: double.tryParse('${json['rating']}'));

  Map<String, dynamic> toJson() => {
        'publisher': publisher.toJson(),
        'costumer': costumer.toJson(),
        'products': products.map((product) => product.toJson()).toList(),
        'totalPrice': totalPrice,
        'status': status,
        'rating': rating
      };
}
