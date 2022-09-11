import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

import 'message_widget.dart';

class MessagesWidget extends StatelessWidget {
  final String chatPathId;
  final String authorId;
  final ValueChanged<Message> onSwipedMessage;

  const MessagesWidget({
    required this.chatPathId,
    required this.onSwipedMessage,
    required this.authorId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Message>>(
        stream: FirebaseMessageApi.getMessages(chatPathId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return buildText('Something went wrong.');
              } else {
                final messages = snapshot.data!;

                return messages.isEmpty
                    ? buildText('Say Hi..')
                    : ListView.builder(
                        physics: BouncingScrollPhysics(),
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];

                          return SwipeTo(
                            onRightSwipe: () => onSwipedMessage(message),
                            child: MessageWidget(
                              message: message,
                              isMe: message.userId == authorId,
                            ),
                          );
                        },
                      );
              }
          }
        },
      );

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 15),
        ),
      );
}
