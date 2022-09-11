import 'dart:async';
import 'package:ani_capstone/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/message.dart';
import '../models/user.dart';

class FirebaseMessageApi {
  static getAuthor(String userId) => FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get()
      .then((DocumentSnapshot documentSnapshot) =>
          User.fromJson(documentSnapshot.data() as Map<String, dynamic>));

  static Stream<List<Message>> getMessages(String chatPathId) =>
      FirebaseFirestore.instance
          .collection('chats')
          .doc(chatPathId)
          .collection('messages')
          .orderBy("createdAt", descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Message.fromJson(doc.data()))
              .toList());

  static Stream<List<User>> getUsers() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());

  static generateChatId(String ids) => const Uuid().v5(Uuid.NAMESPACE_OID, ids);

  static addUserChat(String authorId, String receiverId) async {
    final chatPathId = generateChatId('$authorId-$receiverId').toString();

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
    String chatPathId = '';

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authorId)
          .collection('user_chats')
          .doc(receiverId)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          chatPathId = data['chat_path'];
        } else {
          chatPathId = addUserChat(authorId, receiverId);
        }
      });
    } on Exception catch (e) {
      print(e.toString());
      return '';
    }

    return chatPathId;
  }

  static sendMessage(String chatPathId, String message, User user,
      {Message? replyMessage}) async {
    try {
      var chatPath;

      final chatPathRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatPathId)
          .collection('messages');

      final newMessage = Message(
          message: message,
          userId: user.userId!,
          urlAvatar: user.photoUrl,
          username: user.name,
          createdAt: DateTime.now(),
          replyMessage: replyMessage);

      await chatPathRef.add(newMessage.toJson());
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  // static Future uploadMessage(
  //     String idUser, String message, Message replyMessage) async {
  //   final refMessages =
  //       FirebaseFirestore.instance.collection('chats/$idUser/messages');

  //   final newMessage = Message(
  //     idUser: myId,
  //     urlAvatar: myUrlAvatar,
  //     username: myUsername,
  //     message: message,
  //     createdAt: DateTime.now(),
  //     replyMessage: replyMessage,
  //   );
  //   await refMessages.add(newMessage.toJson());
  // }
}
