import 'package:ani_capstone/api/notification_api.dart';
import 'package:ani_capstone/models/orders.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import 'firebase_filehost.dart';

class ProductPost {
  static Future uploadPost(BuildContext context, {required Post post}) async {
    final posts = FirebaseFirestore.instance.collection('posts');

    try {
      await posts.add(post.toJson());
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  static Future updatePost({required Post post}) => FirebaseFirestore.instance
      .collection('posts')
      .doc(post.postId!)
      .update(post.toJson());

  static Future updatePrice(
          {required String postId, required double newPrice}) =>
      FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update({'price': newPrice});

  static Future deletePost({
    required Post post,
  }) async {
    await FirebaseStorageDb.deleteImages(
        userId: post.publisher.userId!, images: post.images);

    return FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postId)
        .delete();
  }

  static Future<List<Post>> getPosts() => FirebaseFirestore.instance
      .collection('posts')
      .orderBy("postedAt", descending: true)
      .get()
      .then((snapshot) => snapshot.docs
          .map((doc) => Post.fromJson(doc.data(), doc.id))
          .toList());

  static postStream() => FirebaseFirestore.instance
      .collection('posts')
      .orderBy("postedAt", descending: true)
      .snapshots(includeMetadataChanges: false);

  static Future<List<Post>> getUserPosts({required String userId}) =>
      FirebaseFirestore.instance
          .collection('posts')
          .where('publisher.id', isEqualTo: userId)
          .orderBy('postedAt', descending: true)
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => Post.fromJson(doc.data(), doc.id))
              .toList());

  static Future<bool> checkProductLike(
      {required String userId, required String productId}) async {
    final userLikesRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(productId)
        .collection('user_likes')
        .doc(userId);

    bool exist = false;

    try {
      await userLikesRef.get().then((doc) {
        exist = doc.exists;
      });
      return exist;
    } catch (e) {
      return false;
    }
  }

  static Future updateLike(
      {required User user,
      required User publisher,
      required bool liked,
      required String productId}) async {
    final productRef =
        FirebaseFirestore.instance.collection('posts').doc(productId);

    if (liked) {
      await productRef.update({
        'likes': FieldValue.arrayUnion([user.userId])
      });
    } else {
      await productRef.update({
        'likes': FieldValue.arrayRemove([user.userId])
      });
    }

    if (user.userId != publisher.userId) {
      if (liked) {
        NotificationApi.addNotification(
            notifTo: publisher.userId!,
            notifFrom: user,
            title: user.name,
            body: '',
            payload: productId,
            notifType: 1);
      } else {
        NotificationApi.removeNotification(
            notifTo: publisher.userId!,
            notifFrom: user,
            payload: productId,
            notifType: 1);
      }
    }
  }

  static Future addToBasket({
    required String userId,
    required Post post,
  }) async {
    final basketRef = FirebaseFirestore.instance
        .collection('basket')
        .doc(userId)
        .collection('user_basket');

    final product = Product(
            productId: post.postId!,
            quantity: 1,
            orderStatus: 0,
            publisher: post.publisher,
            addedAt: DateTime.now())
        .toJson();

    return await basketRef.doc(post.postId).set(product);
  }

  static Future removeToBasket(
      {required String userId, required List<String> productIds}) async {
    final basketRef = FirebaseFirestore.instance
        .collection('basket')
        .doc(userId)
        .collection('user_basket');

    final batch = FirebaseFirestore.instance.batch();

    for (var productId in productIds) {
      batch.delete(basketRef.doc(productId));
    }

    return await batch.commit();
  }

  static Future<List<Product>> getUserBasket({required String userId}) {
    return FirebaseFirestore.instance
        .collection('basket')
        .doc(userId)
        .collection('user_basket')
        .orderBy("addedAt", descending: true)
        .get()
        .then((snapshot) =>
            snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList());
  }

  static basketStream({required String userId}) => FirebaseFirestore.instance
      .collection('basket')
      .doc(userId)
      .collection('user_basket')
      .orderBy("addedAt", descending: true)
      .snapshots(includeMetadataChanges: false);

  static orderStream({required String userId, required int userType}) {
    final id = userType == 1 ? 'publisher.id' : 'costumer.id';
    return FirebaseFirestore.instance
        .collection('orders')
        .where(id, isEqualTo: userId)
        .snapshots(includeMetadataChanges: false);
  }

  static Future<List<Orders>> getOrders(
      {required String userId, required int userType}) {
    final id = userType == 1 ? 'publisher.id' : 'costumer.id';

    return FirebaseFirestore.instance
        .collection('orders')
        .where(id, isEqualTo: userId)
        .get()
        .then((snapshot) => snapshot.docs
            .map((doc) => Orders.fromJson(doc.data(), doc.id))
            .toList());
  }

  static Future<List<Orders>> getUserOrders({required String userId}) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('costumer.id', isEqualTo: userId)
        .where('status', isGreaterThanOrEqualTo: 3)
        .get()
        .then((snapshot) => snapshot.docs
            .map((doc) => Orders.fromJson(doc.data(), doc.id))
            .toList());
  }

  static Future<List<Post>> getProducts({required List<String> productList}) =>
      FirebaseFirestore.instance
          .collection('posts')
          .where(FieldPath.documentId, whereIn: productList)
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => Post.fromJson(doc.data(), doc.id))
              .toList());

  static Future deleteOrder({required String orderId}) =>
      FirebaseFirestore.instance.collection('orders').doc(orderId).delete();

  static Future updateOrderStatus(
      {required int orderStatus,
      required int userTypeId,
      required Orders orders,
      double? rating}) async {
    final orderRef =
        FirebaseFirestore.instance.collection('orders').doc(orders.orderId!);

    final List<int> notifStatus = [3, 4, 5, 6];

    final update = orderStatus == 4
        ? {'status': orderStatus, 'rating': rating!}
        : {'status': orderStatus};

    await orderRef.update(update).whenComplete(() {
      if (userTypeId == 1) {
        NotificationApi.addNotification(
            notifTo: orders.costumer.userId!,
            notifFrom: orders.publisher,
            title: orders.publisher.name,
            body: '',
            payload: orderRef.id,
            notifType: notifStatus[orderStatus - 1]);
      } else {
        NotificationApi.addNotification(
            notifTo: orders.publisher.userId!,
            notifFrom: orders.costumer,
            title: orders.publisher.name,
            body: '',
            payload: orderRef.id,
            notifType: notifStatus[orderStatus - 1]);
      }
    });
  }

  static Future checkOutOrder(
      {required User costumer,
      required User publisher,
      required List<Product> products,
      required int totalPrice}) async {
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();

    final orders = Orders(
            publisher: publisher,
            costumer: costumer,
            products: products,
            totalPrice: totalPrice,
            status: 0)
        .toJson();

    return await orderRef.set(orders).whenComplete(() =>
        NotificationApi.addNotification(
            notifTo: publisher.userId!,
            notifFrom: costumer,
            title: costumer.name,
            body: '',
            payload: orderRef.id,
            notifType: 2));
  }

  static Future addProductReview(
      {required List<Review> reviews,
      required List<String> productIds,
      required String userId}) {
    final batch = FirebaseFirestore.instance.batch();
    final reviewRef = FirebaseFirestore.instance.collection('reviews');
    final postRef = FirebaseFirestore.instance.collection('posts');

    for (int i = 0; i < productIds.length; i++) {
      batch.update(postRef.doc(productIds[i]), {
        'reviews': FieldValue.arrayUnion([userId])
      });

      batch.set(reviewRef.doc(), reviews[i].toJson());
    }

    return batch.commit();
  }

  static Future<List<Review>> getUserReviews({required String userId}) =>
      FirebaseFirestore.instance
          .collection('reviews')
          .where('reviewer.id', isEqualTo: userId)
          .orderBy('postedAt', descending: true)
          .get()
          .then((snapshots) => snapshots.docs
              .map((doc) => Review.fromJson(doc.data(), doc.id))
              .toList());

  static Future<List<Review>> getProductReviews({required String productId}) =>
      FirebaseFirestore.instance
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy("rating", descending: true)
          .get()
          .then((snapshots) => snapshots.docs
              .map((doc) => Review.fromJson(doc.data(), doc.id))
              .toList());
}
