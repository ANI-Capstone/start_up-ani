import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/notification.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  PostNotification notif;

  NotificationCard({Key? key, required this.notif}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String timeAgo = '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
      child: Container(
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(children: [
            CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(notif.participant.photoUrl)),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: notif.participant.name,
                        style: const TextStyle(
                            fontSize: 14,
                            color: linkColor,
                            fontWeight: FontWeight.bold),
                      ),
                      const WidgetSpan(
                          child: SizedBox(
                        width: 5,
                      )),
                      TextSpan(
                          text: notifBody(),
                          style: const TextStyle(
                            color: linkColor,
                            fontSize: 14,
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    timeAgo.isEmpty
                        ? timeago.format(notif.timestamp, locale: 'en_short')
                        : timeAgo,
                    style: TextStyle(
                        fontSize: 12, color: Colors.black.withOpacity(0.7)),
                  ),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }

  String notifBody() {
    String body = '';

    if (notif.notifType == 2) {
      body = 'make a review of your product.';
    } else {
      body = 'liked your post.';
    }

    return body;
  }
}
