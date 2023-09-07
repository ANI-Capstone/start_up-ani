import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/models/estab_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:collection/collection.dart";

import '../models/product.dart';

class ProductOrderApi {
  static Future addOrder(
      {required String userId, required EstabOrder order}) async {
    // final estabOrderRef = FirebaseFirestore.instance
    //     .collection('establishment_orders')
    //     .doc(userId)
    //     .collection('created_orders');

    final productGroup =
        groupBy(order.products, (Product obj) => obj.publisher.userId).values;

    for (int i = 0; i < productGroup.length; i++) {
      final products = productGroup.toList()[i];

      await ProductPost.checkOutOrder(
          customer: order.orderFrom,
          publisher: products[0].publisher,
          products: products,
          totalPrice: products[0].tPrice!);
    }

    // return estabOrderRef.add(order.toJson());
  }

  static createdOrderStream({required String userId}) =>
      FirebaseFirestore.instance
          .collection('establishment_orders')
          .doc(userId)
          .collection('created_orders')
          .orderBy("createdAt", descending: true)
          .snapshots(includeMetadataChanges: false);

  static Future<List<EstabOrder>> getCreatedOrders({required String userId}) =>
      FirebaseFirestore.instance
          .collection('establishment_orders')
          .doc(userId)
          .collection('created_orders')
          .orderBy('createdAt', descending: true)
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => EstabOrder.fromJson(doc.id, doc.data()))
              .toList());
}
