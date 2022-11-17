import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/api/notification_api.dart';
import 'package:ani_capstone/models/notification.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../notification_page/notification_card.dart';

class UserNotificaiton extends StatefulWidget {
  UserData user;
  UserNotificaiton({Key? key, required this.user}) : super(key: key);

  @override
  State<UserNotificaiton> createState() => _UserNotificaitonState();
}

class _UserNotificaitonState extends State<UserNotificaiton> {
  late UserData user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: StreamBuilder<List<PostNotification>>(
                stream: NotificationApi.getNotification(userId: user.id!),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Text('Something went wrong.');
                  } else if (snapshot.hasData) {
                    final notifs = snapshot.data!;
                    return SizedBox(
                      child: ListView(
                          scrollDirection: Axis.vertical,
                          children: notifs.map(buildNotif).toList()),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })));
  }

  Widget buildNotif(PostNotification notif) => GestureDetector(
        child: NotificationCard(notif: notif),
      );
}
