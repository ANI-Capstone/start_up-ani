import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:meta/meta.dart';

import '../utils.dart';

class Chat {
  String chatPathId;
  User contact;
  Message message;
  DateTime sentAt;

  Chat(
      {required this.chatPathId,
      required this.contact,
      required this.message,
      required this.sentAt});

  static Chat fromJson(Map<String, dynamic> json) => Chat(
      chatPathId: json['chat_path'],
      contact: User.fromJson(json['last_message']['contact']),
      message: Message.fromJson(json['last_message']['message']),
      sentAt: Utils.toDateTime(json['last_message']['sentAt']));

  Map<String, dynamic> toJson() => {
        'chat_path': chatPathId,
        'contact': contact,
        'message': message.toJson(),
        'sentAt': Utils.fromDateTimeToJson(sentAt),
      };
}
