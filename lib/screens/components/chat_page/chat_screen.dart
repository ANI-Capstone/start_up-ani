import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/chat_page/messages_widget.dart';
import 'package:ani_capstone/screens/components/chat_page/new_message.dart';
import 'package:ani_capstone/screens/components/user/user_inbox.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatScreen extends StatefulWidget {
  List<Message>? messages;
  User author;
  User receiver;

  ChatScreen(
      {Key? key, required this.receiver, required this.author, this.messages})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final focusNode = FocusNode();
  Message? replyMessage;
  User? author;
  User? receiver;
  String? authorId;
  String? receiverId;
  String? chatPathId;

  @override
  void initState() {
    super.initState();
    author = widget.author;
    receiver = widget.receiver;
    authorId = widget.author.userId;
    receiverId = widget.receiver.userId;
  }

  @override
  Widget build(BuildContext context) {
    Future getChatPath() async {
      return FirebaseMessageApi.getChatPath(authorId!, receiverId!)
          .then((value) => value);
    }

    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
              color: linkColor,
              onPressed: () {
                Navigator.pop(context, true);
              }),
          backgroundColor: primaryColor,
          toolbarHeight: 60,
          elevation: 0,
          title: Transform.translate(
            offset: const Offset(-24, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(receiver!.photoUrl)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      receiver!.name,
                      style: const TextStyle(
                          color: linkColor, fontSize: 16, fontFamily: 'Roboto'),
                    ),
                  ),
                ),
                const FaIcon(
                  FontAwesomeIcons.phone,
                  color: linkColor,
                  size: 18,
                ),
                Transform.translate(
                  offset: const Offset(20, 0),
                  child: const FaIcon(
                    FontAwesomeIcons.ellipsisVertical,
                    color: linkColor,
                    size: 20,
                  ),
                )
              ],
            ),
          ),
        ),
        body: FutureBuilder(
            future: getChatPath(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong.'));
              } else {
                final chatPathId = snapshot.data.toString();
                return Column(children: [
                  Expanded(
                      child: MessagesWidget(
                    authorId: authorId!,
                    chatPathId: chatPathId,
                    onSwipedMessage: (message) {
                      replyToMessage(message);
                      focusNode.requestFocus();
                    },
                  )),
                  NewMessageWidget(
                    focusNode: focusNode,
                    onCancelReply: cancelReply,
                    replyMessage: replyMessage,
                    chatPathId: chatPathId,
                    author: author!,
                    receiver: receiver!,
                  )
                ]);
              }
            }));
  }

  void replyToMessage(Message message) {
    setState(() {
      replyMessage = message;
    });
  }

  void cancelReply() {
    setState(() {
      replyMessage = null;
    });
  }
}
