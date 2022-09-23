import 'package:ani_capstone/models/chat.dart';

import '../utils.dart';

class MessageNotification {
  String contactId;
  String title;
  String body;
  String payload;
  DateTime timestamp;

  MessageNotification(
      {required this.contactId,
      required this.title,
      required this.body,
      required this.payload,
      required this.timestamp});

  static MessageNotification fromJson(Map<String, dynamic> json) =>
      MessageNotification(
          contactId: json['notif']['userId'],
          title: json['notif']['title'],
          body: json['notif']['body'],
          payload: (json['notif']['payload']),
          timestamp: Utils.toDateTime(json['notif']['timestamp']));

  Map<String, dynamic> toJson() => {
        'userId': contactId,
        'title': title,
        'body': body,
        'payload': payload,
        'timestamp': Utils.fromDateTimeToJson(timestamp),
      };
}
