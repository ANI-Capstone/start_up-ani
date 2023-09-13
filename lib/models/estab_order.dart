import 'package:ani_capstone/models/address.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/utils.dart';

class EstabOrder {
  String? orderId;
  final User orderFrom;
  final String orderName;
  final List<Product> products;
  final double totalAmount;
  final Address location;
  final DateTime dateTime;
  final DateTime createdAt;
  final int? orderStatus;
  double? transactionFee;
  double? totalPayment;

  EstabOrder(
      {this.orderId,
      required this.orderFrom,
      required this.orderName,
      required this.products,
      required this.totalAmount,
      required this.location,
      required this.dateTime,
      required this.createdAt,
      this.orderStatus = 0,
      this.transactionFee,
      this.totalPayment});

  static EstabOrder fromJson(String id, Map<String, dynamic> json) =>
      EstabOrder(
          orderId: id,
          orderFrom: User.fromJson(json['orderFrom']),
          orderName: json['orderName'],
          products: List<Product>.from((json['products'] as Iterable)
              .map((product) => Product.fromJson(product))
              .toList()),
          totalAmount: json['totalAmount'],
          location: Address.fromJson(json['location']),
          dateTime: Utils.toDateTime(json['dateTime']),
          createdAt: Utils.toDateTime(json['createdAt']),
          orderStatus: json['orderStatus'] ?? 0,
          totalPayment: json['totalPayment'],
          transactionFee: json['transactionFee']);

  Map<String, dynamic> toJson() => {
        'orderFrom': orderFrom.toJson(),
        'orderName': orderName,
        'products': products.map((p) => p.toJson()).toList(),
        'totalAmount': totalAmount,
        'location': location.toJson(),
        'dateTime': Utils.fromDateTimeToJson(dateTime),
        'createdAt': Utils.fromDateTimeToJson(createdAt),
        'orderStaus': orderStatus,
        'transactionFee': transactionFee,
        'totalPayment': totalPayment
      };
}
