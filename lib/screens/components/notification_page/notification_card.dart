import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/notification.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatefulWidget {
  NotificationModel notif;

  NotificationCard({Key? key, required this.notif}) : super(key: key);

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    String timeAgo = '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
              radius: 22,
              backgroundColor: primaryColor,
              backgroundImage: CachedNetworkImageProvider(
                  widget.notif.participant.photoUrl)),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.notif.participant.name,
                  style: const TextStyle(
                      fontSize: 13,
                      color: linkColor,
                      fontWeight: FontWeight.bold),
                ),
                const WidgetSpan(
                    child: SizedBox(
                  width: 2,
                )),
                TextSpan(
                    text: notifBody(),
                    style: const TextStyle(
                      color: linkColor,
                      fontSize: 13,
                    )),
              ],
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              timeAgo.isEmpty
                  ? timeago.format(widget.notif.timestamp)
                  : timeAgo,
              style:
                  TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.7)),
            ),
          ),
          trailing: widget.notif.read!
              ? null
              : Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: linkColor.withOpacity(0.7))),
        ),
      ),
    );
  }

  String notifBody() {
    String body = '';

    if (widget.notif.notifType == 2) {
      body = 'ordered your products.';
    } else if (widget.notif.notifType == 3) {
      body = 'accepted your order. It is ready to be picked up.';
    } else if (widget.notif.notifType == 5) {
      body = 'denied your order.';
    } else if (widget.notif.notifType == 4) {
      body = ": How's my products? Please give me a review.";
    } else if (widget.notif.notifType == 6) {
      body = 'posted a review of your product.';
    } else {
      body = 'liked your post.';
    }

    return body;
  }
}
