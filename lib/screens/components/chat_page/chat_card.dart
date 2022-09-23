import 'dart:async';

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/chat.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatCard extends StatelessWidget {
  Chat chat;
  ChatCard({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String timeAgo = '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: 80,
        decoration: const BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                  backgroundImage: NetworkImage(chat.contact.photoUrl),
                  radius: 28),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (chat.contact.name.length < 25)
                              ? chat.contact.name
                              : '${chat.contact.name.toString().characters.take(25)}...',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: unread(chat.message)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: linkColor),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        buildText(chat.message)
                      ]),
                ),
              ),
              Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    timeAgo.isEmpty
                        ? timeago.format(chat.sentAt, locale: 'en_short')
                        : timeAgo,
                    style: TextStyle(
                        color: linkColor,
                        fontSize: 13,
                        fontWeight: unread(chat.message)
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  bool unread(Message message) {
    return message.userId == AccountControl.getUserId() ? false : !message.seen;
  }

  Widget buildText(Message message) {
    String author = message.userId == AccountControl.getUserId() ? 'You: ' : '';
    return Text(
        (message.message.length < 53)
            ? author + message.message
            : '$author${message.message.toString().characters.take(53)}...',
        style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12.5,
            fontWeight: unread(message) ? FontWeight.bold : FontWeight.normal,
            color: linkColor.withOpacity(0.9)));
  }
}
