import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

import '../models/notification.dart';
import '../models/user.dart';

class NotificationApi {
  NotificationApi();

  static int unReadMessages = 0;

  final _localNotifications = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  void selectNotification(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      behaviorSubject.add(payload);
    }
  }

  Future<NotificationDetails> _notificationDetails() async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails('channel id', 'channel name',
            channelDescription: 'channel description',
            importance: Importance.max,
            playSound: true,
            styleInformation: DefaultStyleInformation(true, true));

    IOSNotificationDetails iosNotificationDetails =
        const IOSNotificationDetails(
      threadIdentifier: "thread1",
    );

    // final details = await _localNotifications.getNotificationAppLaunchDetails();
    // if (details != null && details.didNotificationLaunchApp) {
    //   try {
    //     behaviorSubject.add(details.payload!);
    //   } on Exception catch (e) {
    //     null;
    //   }
    // }
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotificationDetails);

    return platformChannelSpecifics;
  }

  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final platformChannelSpecifics = await _notificationDetails();
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<List<NotificationModel>> getNotification(
          {required String userId}) =>
      FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .collection('user_notif')
          .orderBy("timestamp", descending: true)
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromJson(doc.data(), doc.id))
              .toList());

  static notifStream(String userId) => FirebaseFirestore.instance
      .collection('notifications')
      .doc(userId)
      .collection('user_notif')
      .snapshots(includeMetadataChanges: true);

  static Future addNotification(
      {required String notifTo,
      required User notifFrom,
      required String title,
      required String body,
      required String payload,
      required int notifType}) async {
    final notifRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc(notifTo)
        .collection('user_notif');

    String notifId = payload + notifFrom.userId!;

    switch (notifType) {
      case 1:
        notifId = '$notifId-TYPE=1';
        break;
      case 2:
        notifId = '$notifId-TYPE=2';
        break;
      case 3:
        notifId = '$notifId-TYPE=3';
        break;
      case 4:
        notifId = '$notifId-TYPE=4';
        break;
      case 5:
        notifId = '$notifId-TYPE=5';
        break;
    }

    final notif = NotificationModel(
            participant: notifFrom,
            title: title,
            body: body,
            notifType: notifType,
            payload: payload,
            timestamp: DateTime.now())
        .toJson();

    await notifRef.doc(notifId).set(notif);
  }

  static Future markAllRead(
      {required String userId, required List<String> notifIds}) async {
    final notifRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('user_notif');

    final batch = FirebaseFirestore.instance.batch();

    for (var element in notifIds) {
      batch.update(notifRef.doc(element), {'read': true});
    }

    return await batch.commit();
  }

  static removeNotification(
      {required String notifTo,
      required User notifFrom,
      required String payload,
      required int notifType}) async {
    final notifRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc(notifTo)
        .collection('user_notif');

    String notifId = payload + notifFrom.userId!;

    switch (notifType) {
      case 1:
        notifId = '$notifId-TYPE=1';
        break;
      case 2:
        notifId = '$notifId-TYPE=2';
        break;
      case 3:
        notifId = '$notifId-TYPE=3';
        break;
      case 4:
        notifId = '$notifId-TYPE=4';
        break;
      case 5:
        notifId = '$notifId-TYPE=5';
        break;
    }

    await notifRef.doc(notifId).delete();
  }
}
