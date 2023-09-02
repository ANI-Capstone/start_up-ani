import 'package:ani_capstone/models/address.dart';
import 'package:ani_capstone/models/product_order.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/utils.dart';

class EstabOrder {
  String? orderId;
  final User orderFrom;
  final String orderName;
  final List<ProductOrder> products;
  final Address location;
  final DateTime dateTime;

  EstabOrder(
      {this.orderId,
      required this.orderFrom,
      required this.orderName,
      required this.products,
      required this.location,
      required this.dateTime});

  static EstabOrder fromJson(String id, Map<String, dynamic> json) =>
      EstabOrder(
          orderId: id,
          orderFrom: User.fromJson(json['orderFrom']),
          orderName: json['orderName'],
          products: List.from(json['products'])
              .map((p) => ProductOrder.fromJson(p))
              .toList(),
          location: Address.fromJson(json['address']),
          dateTime: Utils.toDateTime(json['dateTime']));

  Map<String, dynamic> toJson() => {
        'orderFrom': orderFrom.toJson(),
        'orderName': orderName,
        'products': products.map((p) => p.toJson()).toList(),
        'location': location.toJson(),
        'dateTime': Utils.fromDateTimeToJson(dateTime)
      };
}
