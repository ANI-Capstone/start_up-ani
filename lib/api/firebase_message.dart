import 'dart:async';
import 'package:ani_capstone/models/chat.dart';
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

  static Stream<List<Message>> getMessages(String chatPathId) {
    var messages;
    try {
      messages = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatPathId)
          .collection('messages')
          .orderBy("createdAt", descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Message.fromJson(doc.data()))
              .toList());
    } on Exception catch (e) {
      return messages;
    }

    return messages;
  }

  static Stream<List<User>> getUsers() => FirebaseFirestore.instance
      .collection('users')
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
    } on TypeError catch (e) {
      chatPathId = generateChatId('$authorId-$receiverId').toString();
      addUserChat(chatPathId, authorId, receiverId).toString();
    }

    return chatPathId;
  }

  static setNotification(userId) async {
    final notifRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('message')
        .doc('message_notif');

    final notification = {
      "timestamp": Utils.fromDateTimeToJson(DateTime.now())
    };

    try {
      await notifRef.get().then((value) {
        if (!value.exists) {
          return notifRef.set(notification);
        }
      });
    } on Exception catch (e) {
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
  }

  static sendMessage(String chatPathId, String message, User author,
      User receiver, String type,
      {Message? replyMessage}) async {
    final chatPathRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatPathId)
        .collection('messages');

    final newMessage = Message(
        message: message,
        userId: author.userId!,
        urlAvatar: author.photoUrl,
        username: author.name,
        createdAt: DateTime.now(),
        replyMessage: replyMessage,
        type: type,
        seen: false);

    await chatPathRef.add(newMessage.toJson());
    await setLatestMessage(author, receiver, newMessage);
    await setNotification(author.userId);
    await setNotification(receiver.userId);
  }

  static readMessage(String author, String receiver, Message message) {
    final authorRef = FirebaseFirestore.instance
        .collection('users')
        .doc(author)
        .collection('user_chats')
        .doc(receiver);

    final latestMessageB = {
      "last_message": {
        "message": {"seen": true},
      }
    };

    if (message.userId != author) {
      authorRef.update(latestMessageB);
    }
  }

  static Future<List<Chat>> getChats(String userId) {
    final chats = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('user_chats')
        .orderBy('last_message.sentAt', descending: true)
        .get()
        .then((chats) =>
            chats.docs.map((doc) => Chat.fromJson(doc.data())).toList());

    return chats;
  }

  static Stream chatStream(String userId) => FirebaseFirestore.instance
      .collection('notifications')
      .doc(userId)
      .collection('message')
      .doc('message_notif')
      .snapshots(includeMetadataChanges: true);
}
