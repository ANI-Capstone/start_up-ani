import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
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

    InitializationSettings initializationSettings =
        const InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotifications.initialize(initializationSettings);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  void selectNotification(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      behaviorSubject.add(payload);
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';

    File(filePath).exists().then((value) async {
      if (value) {
        return null;
      } else {
        final http.Response response = await http.get(Uri.parse(url));
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
      }
    });

    return filePath;
  }

  Future<NotificationDetails> _notificationDetails(
      String imageUrl, String imageName) async {
    String largeIconPath = await _downloadAndSaveFile(imageUrl, imageName);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'high_importance_channel', // id
            'High Importance Notifications', // title
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            playSound: true,
            largeIcon: FilePathAndroidBitmap(largeIconPath),
            styleInformation: const DefaultStyleInformation(true, true));

    // final details = await _localNotifications.getNotificationAppLaunchDetails();
    // if (details != null && details.didNotificationLaunchApp) {
    //   try {
    //     behaviorSubject.add(details.payload!);
    //   } on Exception catch (e) {
    //     null;
    //   }
    // }
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    return platformChannelSpecifics;
  }

  // Future<void> showLocalNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required String payload,
  // }) async {
  //   final platformChannelSpecifics = await _notificationDetails();
  //   await _localNotifications.show(
  //     id,
  //     title,
  //     body,
  //     platformChannelSpecifics,
  //     payload: payload,
  //   );
  // }

  Future<AndroidBitmap> getImageBytes(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));

    AndroidBitmap androidBitmap = ByteArrayAndroidBitmap.fromBase64String(
        base64.encode(response.bodyBytes)); //Uint8List

    return androidBitmap;
  }

  Future<void> showMessageNotification(
      {required RemoteNotification notification}) async {
    if (notification.body == null) return;

    print(notification.body);

    // final platformChannelSpecifics =
    //     await _notificationDetails(notification.body, body['iconName']);

    // await _localNotifications.show(
    //   notification.hashCode,
    //   notification.title,
    //   body['description'],
    //   platformChannelSpecifics,
    // );
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

  // static notifStream(String userId) => FirebaseFirestore.instance
  //     .collection('notifications')
  //     .doc(userId)
  //     .collection('user_notif')
  //     .snapshots(includeMetadataChanges: true);

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
            notified: false,
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

  static void notified({required String userId, required String notifId}) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(userId)
        .collection('user_notif')
        .doc(notifId)
        .update({'notified': true});
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
