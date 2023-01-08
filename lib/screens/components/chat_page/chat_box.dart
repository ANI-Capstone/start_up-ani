import 'dart:async';

import 'package:ani_capstone/api/account_api.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/chat_page/message_widget.dart';
import 'package:ani_capstone/screens/components/chat_page/new_message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ChatBox extends StatefulWidget {
  List<Message>? messages;
  UserData author;
  User receiver;

  ChatBox({
    Key? key,
    required this.author,
    required this.receiver,
    this.messages,
  }) : super(key: key);

  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  Message? replyMessage;
  User? author;
  User? receiver;
  String? authorId;
  String? receiverId;
  String? chatPathId;

  bool isGetChatPathId = false;

  late SharedPreferences prefs;
  late StreamSubscription listener;

  List<Message> messages = [];

  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    author = User(
        name: widget.author.name,
        photoUrl: widget.author.photoUrl!,
        userId: widget.author.id!);
    receiver = widget.receiver;
    authorId = widget.author.id;
    receiverId = widget.receiver.userId;

    getChatPath();
  }

  @override
  void dispose() {
    super.dispose();
    listener.cancel();
  }

  void readMessage() {
    FirebaseMessageApi.readMessage(authorId!, receiverId!, messages.last);
  }

  void getChatPath() async {
    prefs = await SharedPreferences.getInstance();

    final prefChatPathId = prefs.getString('${authorId!} + $receiverId');

    if (prefChatPathId != null && mounted) {
      setState(() {
        chatPathId = prefChatPathId;
        isGetChatPathId = true;
        getMessages();
        messageListener();
      });
    } else {
      FirebaseMessageApi.getChatPath(authorId!, receiverId!)
          .then((value) async {
        if (mounted) {
          setState(() {
            chatPathId = value;
            isGetChatPathId = true;
            getMessages();
            messageListener();
          });
        }

        await prefs.setString('${authorId!} + $receiverId', chatPathId!);
      });
    }
  }

  void getMessages() async {
    await FirebaseMessageApi.getMessages(chatPathId: chatPathId!).then((data) {
      if (mounted) {
        setState(() {
          messages = data;
        });
      }
      readMessage();
    });
  }

  void messageListener() async {
    final messageRef = FirebaseMessageApi.messageStream(chatPathId!);

    listener = messageRef.listen((event) async {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final latest = change.doc.data() as Map<String, dynamic>;

          if (mounted && !isMe(latest['idUser'])) {
            setState(() {
              messages.add(
                  Message.fromJson(change.doc.data() as Map<String, dynamic>));
            });
          }
        }
      }
    });
  }

  void sendImage(String message, Message? replyMessage) {
    final messageIndex = messages.length;

    final imageMessage = Message(
        userId: authorId!,
        urlAvatar: author!.photoUrl,
        username: author!.name,
        message: message,
        createdAt: DateTime.now(),
        status: 0,
        typeId: 1,
        seen: false);

    if (mounted) {
      setState(() {
        messages.add(imageMessage);
        messages[messageIndex].index = messageIndex;
      });
    }
  }

  void sendText(String message, Message? replyMessage) async {
    final messageIndex = messages.length;

    final textMessage = Message(
        userId: authorId!,
        urlAvatar: author!.photoUrl,
        username: author!.name,
        message: message,
        createdAt: DateTime.now(),
        status: 0,
        typeId: 0,
        seen: false);

    if (mounted) {
      setState(() {
        messages.add(textMessage);
      });
    }

    sendMessage(message, replyMessage, messageIndex);
  }

  void sendMessage(
      String message, Message? replyMessage, int messageIndex) async {
    try {
      await FirebaseMessageApi.sendMessage(chatPathId!, message, author!,
              receiver!, messages[messageIndex].typeId!,
              replyMessage: replyMessage)
          .then((value) {
        if (value) {
          if (mounted) {
            setState(() {
              messages[messageIndex].createdAt = DateTime.now();
              messages[messageIndex].status = 1;
            });
          }
        }
      });
    } on Exception catch (_) {
      null;
    }

    focusNode.requestFocus();
  }

  void cancelSend(int messageIndex) {
    if (mounted) {
      setState(() {
        messages.removeAt(messageIndex);
      });
      focusNode.requestFocus();
    }
  }

  Future<void> _dialCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: primaryColor,
                  backgroundImage:
                      CachedNetworkImageProvider(receiver!.photoUrl)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    receiver!.name,
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ShoWInfo.showLoadingDialog(context,
                      message: 'Getting contact info...');
                  AccountApi.getUserData(widget.receiver.userId!).then((value) {
                    Navigator.of(context).pop();

                    ShoWInfo.showUpDialog(context,
                        title: 'Dial Phone',
                        message: "Dial this contact number ${value.phone}?",
                        action1: "Yes",
                        action2: "No", btn1: () {
                      Navigator.of(context).pop();
                      _dialCall(value.phone);
                    }, btn2: () {
                      Navigator.of(context).pop();
                    });
                  });
                },
                child: const FaIcon(
                  FontAwesomeIcons.phone,
                  color: linkColor,
                  size: 18,
                ),
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
      backgroundColor: Colors.white,
      body: !isGetChatPathId
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Expanded(
                  child: messages.isEmpty
                      ? const SizedBox()
                      : GroupedListView<Message, DateTime>(
                          order: GroupedListOrder.DESC,
                          reverse: true,
                          elements: messages,
                          cacheExtent: messages.length * 60,
                          groupBy: (message) => DateTime(
                                message.createdAt.year,
                                message.createdAt.month,
                                message.createdAt.day,
                                message.createdAt.hour,
                              ),
                          groupHeaderBuilder: (Message message) => Center(
                                  child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(buildDate(message),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.7),
                                    )),
                              )),
                          itemComparator: (item1, item2) =>
                              item1.createdAt.compareTo(item2.createdAt),
                          indexedItemBuilder: (context, message, index) {
                            return messageBuilder(
                                message, isLastMessage(message.userId, index));
                          })),
              NewMessageWidget(
                focusNode: focusNode,
                onCancelReply: cancelReply,
                replyMessage: replyMessage,
                sendImage: sendImage,
                sendText: sendText,
              )
            ]),
    );
  }

  String buildDate(Message message) {
    final dateNow = DateFormat('MMM dd, yyyy').format(DateTime.now());
    final createdAt = DateFormat('MMM dd, yyyy').format(message.createdAt);

    return createdAt == dateNow
        ? DateFormat('hh:mm a').format(message.createdAt)
        : DateFormat('MMM d, yyyy hh:mm a').format(message.createdAt);
  }

  bool isLastMessage(String userId, int index) => index == 0 && isMe(userId);

  bool isMe(String userId) => userId == authorId;

  Widget messageBuilder(Message message, bool showStatus) => MessageWidget(
        message: message,
        isMe: isMe(message.userId),
        showStatus: showStatus,
        chatPathId: chatPathId!,
        author: author!,
        receiver: receiver!,
        sendMessage: (message, replyMessage, index) {
          sendMessage(message, replyMessage, index!);
        },
        cancelSend: (messageIndex) {
          cancelSend(messageIndex);
        },
        onSwipedMessage: (message) {
          replyToMessage(message);
          focusNode.requestFocus();
        },
      );

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 15),
        ),
      );

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
