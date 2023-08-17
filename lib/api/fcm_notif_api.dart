import 'dart:async';
import 'dart:convert';

import 'package:ani_capstone/api/notification_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

final notifChannel = NotificationApi();

class NotifAPI {
  static final firebaseMessaging = FirebaseMessaging.instance;
  static late StreamSubscription<RemoteMessage> notifListener;

  static Future<void> initNotification() async {
    await firebaseMessaging.requestPermission();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    notifListener = FirebaseMessaging.onMessage.listen((event) {
      final notification = event.notification;
      if (notification == null) return;
      notifChannel.showMessageNotification(notification: notification);
    });
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await setupFlutterNotifications();
  // showFlutterNotification(message);

  notifChannel.showMessageNotification(notification: message.notification!);
}

// Future<void> setupFlutterNotifications() async {
//   if (isFlutterLocalNotificationsInitialized) {
//     return;
//   }
//   channel = const AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.high,
//   );

//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//   isFlutterLocalNotificationsInitialized = true;
// }
