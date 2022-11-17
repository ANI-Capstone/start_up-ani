import 'package:ani_capstone/models/chat.dart';
import 'package:ani_capstone/models/user.dart';

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

class PostNotification {
  User participant;
  int notifType;
  String postId;
  DateTime timestamp;
  bool? unread;
  String? notifId;
  bool hide;

  PostNotification(
      {required this.participant,
      required this.notifType,
      required this.postId,
      required this.timestamp,
      this.unread = true,
      this.notifId,
      this.hide = false});

  static PostNotification fromJson(Map<String, dynamic> json, String notifId) =>
      PostNotification(
          participant: User.fromJson(json['participant']),
          notifType: json['notifType'],
          postId: json['postId'],
          timestamp: Utils.toDateTime(json['timestamp']),
          unread: json['unread'],
          notifId: notifId,
          hide: json['hide']);

  Map<String, dynamic> toJson() => {
        'participant': participant.toJson(),
        'notifType': notifType,
        'postId': postId,
        'timestamp': Utils.fromDateTimeToJson(timestamp),
        'unread': unread,
        'hide': hide
      };
}
