import 'package:meta/meta.dart';

import '../utils.dart';

class MessageField {
  static final String message = 'message';
  static final String createdAt = 'createdAt';
}

class Message {
  final String userId;
  final String urlAvatar;
  final String username;
  final String message;
  final DateTime createdAt;
  final Message? replyMessage;

  const Message({
    required this.userId,
    required this.urlAvatar,
    required this.username,
    required this.message,
    required this.createdAt,
    this.replyMessage,
  });

  static Message fromJson(Map<String, dynamic> json) => Message(
        userId: json['idUser'],
        urlAvatar: json['urlAvatar'],
        username: json['username'],
        message: json['message'],
        createdAt: Utils.toDateTime(json['createdAt']),
        replyMessage: json['replyMessage'] == null
            ? null
            : Message.fromJson(json['replyMessage']),
      );

  Map<String, dynamic> toJson() => {
        'idUser': userId,
        'urlAvatar': urlAvatar,
        'username': username,
        'message': message,
        'createdAt': Utils.fromDateTimeToJson(createdAt),
        'replyMessage': replyMessage == null ? null : replyMessage?.toJson(),
      };
}
