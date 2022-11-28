import 'package:ani_capstone/models/notification.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

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

  static Stream<List<Post>> getPosts() => FirebaseFirestore.instance
      .collection('posts')
      .orderBy("postedAt", descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
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
      required String publisherId,
      required bool liked,
      required String productId,
      required int likes}) async {
    final productRef =
        FirebaseFirestore.instance.collection('posts').doc(productId);

    final newLikes = {'likes': likes};

    await productRef.update(newLikes);

    final userLikesRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(productId)
        .collection('user_likes')
        .doc(user.userId);

    if (liked) {
      final likeData = {"liked": liked};
      await userLikesRef.set(likeData);
    } else {
      await userLikesRef.delete();
    }

    if (user.userId != publisherId) {
      final postNotifRef = FirebaseFirestore.instance
          .collection('notifications')
          .doc(publisherId)
          .collection('posts')
          .doc('${user.userId}$productId');

      bool exist = false;
      bool hidden = false;

      final newNotification = PostNotification(
              participant: user,
              notifType: 1,
              postId: productId,
              timestamp: DateTime.now())
          .toJson();

      try {
        await postNotifRef.get().then((doc) {
          exist = doc.exists;

          if (exist) {
            final data = doc.data() as Map<String, dynamic>;
            hidden = data['hide'];
          }
        });

        if (hidden) return;

        if (exist) {
          await postNotifRef.update({'hide': true});
        } else {
          await postNotifRef.set(newNotification);
        }
      } catch (_) {
        return;
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

  static Future removeToBasket({
    required String userId,
    required String productId,
  }) async {
    final basketRef = FirebaseFirestore.instance
        .collection('basket')
        .doc(userId)
        .collection('user_basket');

    return await basketRef.doc(productId).delete();
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
      .snapshots(includeMetadataChanges: true);

  static Future<List<Post>> getProducts({required List<String> productList}) =>
      FirebaseFirestore.instance
          .collection('posts')
          .where(FieldPath.documentId, whereIn: productList)
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => Post.fromJson(doc.data(), doc.id))
              .toList());

  static Future updateOrderStatus(
      {required String userId,
      required List<Product?> product,
      required int status}) async {
    final batch = FirebaseFirestore.instance.batch();

    final productRef = FirebaseFirestore.instance
        .collection('basket')
        .doc(userId)
        .collection('user_basket');

    product.map((product) {
      batch.update(productRef.doc(product!.productId),
          {'orderStatus': status, 'quantity': product.quantity});
    });

    return await batch.commit();
  }
}
