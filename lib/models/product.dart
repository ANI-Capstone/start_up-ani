// ignore_for_file: unnecessary_null_in_if_null_operators

import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/utils.dart';

class Product {
  String productId;
  int quantity;
  int orderStatus;
  User publisher;
  DateTime addedAt;
  Post? post;
  bool? checkBox;
  int? tPrice;
  int? index;
  int? basketIndex;

  Product(
      {required this.productId,
      required this.quantity,
      required this.orderStatus,
      required this.publisher,
      required this.addedAt,
      this.post,
      this.checkBox = false,
      this.tPrice});

  static Product fromJson(Map<String, dynamic> json) => Product(
      productId: json['productId'],
      quantity: json['quantity'],
      orderStatus: json['orderStatus'],
      publisher: User.fromJson(json['publisher']),
      addedAt: Utils.toDateTime(json['addedAt']),
      tPrice: json['tPrice'],
      post: json['post'] == null
          ? null
          : Post.fromJson(json['post'], json['productId']));

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
        'orderStatus': orderStatus,
        'publisher': publisher.toJson(),
        'addedAt': Utils.fromDateTimeToJson(addedAt),
        'tPrice': tPrice,
        'post': post == null ? null : post!.toJson()
      };
}
