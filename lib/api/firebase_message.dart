import 'dart:async';
import 'package:ani_capstone/models/chat.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message.dart';
import '../models/user.dart';
import '../utils.dart';

class FirebaseMessageApi {
  static getAuthor(String userId) => FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get()
      .then((DocumentSnapshot documentSnapshot) =>
          User.fromJson(documentSnapshot.data() as Map<String, dynamic>));

  static Future<List<Message>> getMessages({required String chatPathId}) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatPathId)
        .collection('messages')
        .orderBy("createdAt", descending: true)
        .get()
        .then((messages) =>
            messages.docs.map((doc) => Message.fromJson(doc.data())).toList());
  }

  static messageStream(String chatPathId) => FirebaseFirestore.instance
      .collection('chats')
      .doc(chatPathId)
      .collection('messages')
      .snapshots();

  static Stream<List<User>> getUsers({required String userId}) =>
      FirebaseFirestore.instance
          .collection('users')
          .where('id', isNotEqualTo: userId)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());

  static generateChatId(String ids) => const Uuid().v5(Uuid.NAMESPACE_OID, ids);

  static Future<String> addUserChat(
      String chatPathId, String authorId, String receiverId) async {
    final authorRef = FirebaseFirestore.instance
        .collection('users')
        .doc(authorId)
        .collection('user_chats')
        .doc(receiverId);

    final receiverRef = FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('user_chats')
        .doc(authorId);

    final chatPath = {"chat_path": chatPathId, "last_message": null};

    await authorRef.set(chatPath);
    await receiverRef.set(chatPath);

    return chatPathId;
  }

  static Future<String> getChatPath(String authorId, String receiverId) async {
    var chatPathId = '';

    final userChatsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(authorId)
        .collection('user_chats')
        .doc(receiverId);

    try {
      await userChatsRef.get().then((value) {
        if (value.data() != null) {
          final data = value.data() as Map<String, dynamic>;
          chatPathId = data['chat_path'].toString();
        } else {
          chatPathId = generateChatId('$authorId-$receiverId').toString();
          addUserChat(chatPathId, authorId, receiverId).toString();
        }
      });
    } on TypeError catch (_) {
      chatPathId = generateChatId('$authorId-$receiverId').toString();
      addUserChat(chatPathId, authorId, receiverId).toString();
    }

    return chatPathId;
  }

  static setNotification(
      {String? userId,
      String? contactId,
      String? name,
      String? message,
      String? payload}) async {
    final notifRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('message')
        .doc('message_notif');

    final notification = {
      'notification': {
        "type": 0,
        "type_name": "MESSAGE",
        "notif": {
          'contactId': contactId,
          'title': name,
          'body': message,
          'payload': payload,
          'timestamp': Utils.fromDateTimeToJson(DateTime.now())
        }
      }
    };

    try {
      await notifRef.get().then((value) {
        if (!value.exists) {
          return notifRef.set(notification);
        }
      });
    } on Exception catch (_) {
      return notifRef.set(notification);
    }

    await notifRef.update(notification);
  }

  static setLatestMessage(User author, User receiver, Message message) async {
    final authorRef = FirebaseFirestore.instance
        .collection('users')
        .doc(author.userId)
        .collection('user_chats')
        .doc(receiver.userId);

    final receiverRef = FirebaseFirestore.instance
        .collection('users')
        .doc(receiver.userId)
        .collection('user_chats')
        .doc(author.userId);

    final latestMessageA = {
      "last_message": {
        "contact": receiver.toJson(),
        "message": message.toJson(),
        "sentAt": Utils.fromDateTimeToJson(DateTime.now())
      }
    };

    final latestMessageB = {
      "last_message": {
        "contact": author.toJson(),
        "message": message.toJson(),
        "sentAt": Utils.fromDateTimeToJson(DateTime.now())
      }
    };

    await authorRef.update(latestMessageA);
    await receiverRef.update(latestMessageB);

    return [latestMessageA, latestMessageB];
  }

  static Future sendMessage(
      String chatPathId, String message, User author, User receiver, int typeId,
      {Message? replyMessage}) async {
    bool sent = false;

    final chatPathRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatPathId)
        .collection('messages');

    final newMessage = Message(
        message: message,
        userId: author.userId!,
        urlAvatar: author.photoUrl,
        username: author.name,
        fcmToken: receiver.fcmToken,
        createdAt: DateTime.now(),
        replyMessage: replyMessage,
        typeId: typeId,
        status: 1,
        seen: false);

    try {
      await chatPathRef.add(newMessage.toJson()).whenComplete(() {
        sent = true;
      });
    } on Exception catch (_) {
      sent = false;
    }

    final messages = await setLatestMessage(author, receiver, newMessage);

    await setNotification(
        userId: author.userId,
        contactId: messages[0]['last_message']['message']['idUser'],
        name: messages[0]['last_message']['message']['username'],
        message: messages[0]['last_message']['message']['message'],
        payload: chatPathId);

    await setNotification(
        userId: receiver.userId,
        contactId: messages[1]['last_message']['message']['idUser'],
        name: messages[1]['last_message']['message']['username'],
        message: messages[1]['last_message']['message']['message'],
        payload: chatPathId);

    return sent;
  }

  static readMessage(String author, String receiver, Message message) {
    final authorRef = FirebaseFirestore.instance
        .collection('users')
        .doc(author)
        .collection('user_chats')
        .doc(receiver);

    if (message.userId != author) {
      authorRef.update({
        'last_message.message.seen': true,
      });
    }
  }

  static chatStream(String userId) => FirebaseFirestore.instance
      .collection('notifications')
      .doc(userId)
      .collection('message')
      .snapshots(includeMetadataChanges: true);

  static Future<List<Chat>> getChats(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('user_chats')
        .orderBy('last_message.sentAt', descending: true)
        .get()
        .then((chats) =>
            chats.docs.map((doc) => Chat.fromJson(doc.data())).toList());
  }

  static updateStatus({required String chatPathId, required int status}) async {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatPathId)
        .collection('order_status')
        .doc('status')
        .update({'status': status});
  }

  static Future getStatus({required String chatPathId}) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatPathId)
        .collection('order_status')
        .doc('status')
        .get()
        .then((value) => value.data());
  }

  static Future<List<Product>> getUserBag({required String chatPathId}) =>
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatPathId)
          .collection('user_bag')
          .get()
          .then((docs) =>
              docs.docs.map((doc) => Product.fromJson(doc.data())).toList());

  // static addToBag(
  //     {required Post post, required String chatPathId, int? quantity}) async {
  //   final product = Product(post: post, quantity: quantity).toJson();

  //   final userBagRef =
  //       FirebaseFirestore.instance.collection('chats').doc(chatPathId);

  //   await userBagRef
  //       .collection('order_status')
  //       .doc('status')
  //       .set({'status': 0});

  //   return userBagRef.collection('user_bag').doc('${post.postId}').set(product);
  // }

  static removeToBag(
      {required String chatPathId, required String productId}) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatPathId)
        .collection('user_bag')
        .doc(productId)
        .delete();
  }

  static removeAllToBag({required String chatPathId}) async {
    final instance = FirebaseFirestore.instance;
    final batch = instance.batch();

    final snapshots = await instance
        .collection('chats')
        .doc(chatPathId)
        .collection('user_bag')
        .get();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
