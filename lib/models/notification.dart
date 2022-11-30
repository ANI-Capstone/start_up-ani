import 'package:ani_capstone/models/user.dart';

import '../utils.dart';

class NotificationModel {
  String? notifId;
  User participant;
  String title;
  String body;
  int notifType;
  String payload;
  DateTime timestamp;
  bool? read;
  bool? hide;

  NotificationModel(
      {required this.participant,
      required this.title,
      required this.body,
      required this.notifType,
      required this.payload,
      required this.timestamp,
      this.read = false,
      this.hide = false,
      this.notifId});

  static NotificationModel fromJson(
          Map<String, dynamic> json, String notifId) =>
      NotificationModel(
          participant: User.fromJson(json['participant']),
          title: json['title'],
          body: json['body'],
          notifType: json['notifType'],
          payload: json['payload'],
          timestamp: Utils.toDateTime(json['timestamp']),
          read: json['read'],
          hide: json['hide'],
          notifId: notifId);

  Map<String, dynamic> toJson() => {
        'participant': participant.toJson(),
        'title': title,
        'body': body,
        'notifType': notifType,
        'payload': payload,
        'timestamp': Utils.fromDateTimeToJson(timestamp),
        'read': read,
        'hide': hide
      };
}
