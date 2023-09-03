import 'package:ani_capstone/models/estab_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductOrderApi {
  static Future addOrder(
      {required String userId, required EstabOrder order}) async {
    final estabOrderRef = FirebaseFirestore.instance
        .collection('establishment_orders')
        .doc(userId)
        .collection('created_orders');

    return estabOrderRef.add(order.toJson());
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
