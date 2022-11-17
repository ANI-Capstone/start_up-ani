import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

import '../models/notification.dart';

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

  static Stream<int> unreadMessages() async* {
    yield unReadMessages;
  }

  static Stream<List<PostNotification>> getNotification(
          {required String userId}) =>
      FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .collection('posts')
          .orderBy("timestamp", descending: true)
          .where('hide', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PostNotification.fromJson(doc.data(), doc.id))
              .toList());
}
