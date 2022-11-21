import 'package:ani_capstone/models/notification.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class ProductPost {
  static Future uploadPost(BuildContext context, {required Post post}) async {
    final posts = FirebaseFirestore.instance.collection('posts');

    try {
      await posts.add(post.toJson());
      return true;
    } on Exception catch (e) {
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
      } catch (e) {
        print(e);
      }
    }
  }
}
