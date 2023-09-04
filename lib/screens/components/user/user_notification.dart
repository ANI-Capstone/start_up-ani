import 'dart:async';

import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/api/notification_api.dart';
import 'package:ani_capstone/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../constants.dart';
import '../notification_page/notification_card.dart';

class UserNotificaiton extends StatefulWidget {
  UserData user;
  Function(int count) setBadge;
  UserNotificaiton({Key? key, required this.user, required this.setBadge})
      : super(key: key);

  @override
  State<UserNotificaiton> createState() => _UserNotificaitonState();
}

class _UserNotificaitonState extends State<UserNotificaiton> {
  late UserData user;
  late StreamSubscription listener;
  late final NotificationApi notificationService;

  int notifCount = 0;
  List<NotificationModel> notifs = [];
  int fetchState = 0;

  @override
  void initState() {
    super.initState();
    user = widget.user;

    getNotifications();
    notifListener();

    notificationService = NotificationApi();
    notificationService.initializePlatformNotifications();
  }

  @override
  void dispose() {
    super.dispose();
    listener.cancel();
  }

  void notifListener() {
    // final notifRef = NotificationApi.notifStream(user.id!);

    // listener = notifRef.listen((event) async {
    //   getNotifications();
    // });
  }

  void showLocalNotification(NotificationModel notif) async {
    // await notificationService
    //     .showLocalNotification(
    //         id: 1,
    //         title: notif.title,
    //         body: notifBody(notif.notifType),
    //         payload: notif.payload)
    //     .whenComplete(() => NotificationApi.notified(
    //         userId: widget.user.id!, notifId: notif.notifId!));
  }

  void getNotifications() async {
    NotificationApi.getNotification(userId: user.id!).then((notif) {
      int sum = 0;

      if (notif.isNotEmpty) {
        for (var unread in notif) {
          if (!unread.read!) {
            sum += 1;
          }

          if (!unread.notified!) {
            showLocalNotification(unread);
          }
        }

        if (mounted) {
          setState(() {
            notifs = notif;
            fetchState = 1;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            fetchState = 2;
          });
        }
      }

      notifCount = sum;
      setState(() {
        widget.setBadge(sum);
      });
    }).onError((error, stackTrace) {
      if (mounted) {
        setState(() {
          fetchState = -1;
        });
      }
    });
  }

  void markAllRead() async {
    List<String> notifIds = [];

    for (var notifId in notifs) {
      notifIds.add(notifId.notifId!);
    }

    NotificationApi.markAllRead(userId: user.id!, notifIds: notifIds)
        .whenComplete(() => ShoWInfo.showToast('Marked as read.', 3));
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('notification-screen'),
      onVisibilityChanged: (info) {
        if ((info.visibleFraction * 100) == 100 && notifCount > 0) {
          markAllRead();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(
              child: Row(
                children: const [
                  Text('NOTIFICATIONS',
                      style: TextStyle(
                          color: linkColor, fontWeight: FontWeight.bold))
                ],
              ),
            ),
            backgroundColor: primaryColor,
            elevation: 0,
          ),
          backgroundColor: userBgColor,
          body: SafeArea(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: fetchState != 1
                ? statusBuilder()
                : Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: notifs.map(buildNotif).toList()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25, top: 10),
                        child: GestureDetector(
                          onTap: () {
                            markAllRead();
                          },
                          child: Container(
                              height: 40,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: primaryColor),
                              child: const Center(
                                  child: Text('Mark all as read',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)))),
                        ),
                      )
                    ],
                  ),
          ))),
    );
  }

  Widget statusBuilder() {
    if (fetchState == 2) {
      return const Center(child: Text('Notification is empty.'));
    } else if (fetchState == -1) {
      return const Center(child: Text('An error occured, please try again.'));
    } else {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }

  Widget buildNotif(NotificationModel notif) {
    return GestureDetector(
      child: NotificationCard(notif: notif),
    );
  }

  String notifBody(int notifType) {
    String body = '';

    if (notifType == 2) {
      body = 'Hello, I ordered your products.';
    } else if (notifType == 3) {
      body = 'Your order has been accepted. It is ready to be picked up.';
    } else if (notifType == 5) {
      body = 'Oops, I denied your order. You can ask me for the reason.';
    } else if (notifType == 4) {
      body = "Hello, how's my products? Please give me a review.";
    } else if (notifType == 6) {
      body = 'Posted a review of your product.';
    } else {
      body = 'Liked your post.';
    }

    return body;
  }
}
