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
          contactId: json['notification']['notif']['contactId'],
          title: json['notification']['notif']['title'],
          body: json['notification']['notif']['body'],
          payload: (json['notification']['notif']['payload']),
          timestamp:
              Utils.toDateTime(json['notification']['notif']['timestamp']));

  Map<String, dynamic> toJson() => {
        'userId': contactId,
        'title': title,
        'body': body,
        'payload': payload,
        'timestamp': Utils.fromDateTimeToJson(timestamp),
      };
}
