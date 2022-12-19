import 'dart:io';

import 'package:ani_capstone/api/firebase_filehost.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/chat_page/reply_widget.dart';
import 'package:ani_capstone/screens/components/widgets/image_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';

class MessageWidget extends StatefulWidget {
  final Message message;
  final bool isMe;
  final bool showStatus;
  String chatPathId;
  User author;
  User receiver;
  Message? replyMessage;
  bool showButton = true;

  final ValueChanged<Message> onSwipedMessage;
  final Function(String message, Message? replyMessage, int? messageIndex)
      sendMessage;
  final Function(int messageIndex) cancelSend;

  MessageWidget(
      {Key? key,
      required this.message,
      required this.isMe,
      required this.showStatus,
      required this.onSwipedMessage,
      required this.chatPathId,
      required this.author,
      required this.receiver,
      required this.sendMessage,
      required this.cancelSend,
      this.replyMessage})
      : super(key: key);

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  bool sent = false;

  String? chatPathId;
  User? author;
  User? receiver;

  @override
  void initState() {
    super.initState();
    chatPathId = widget.chatPathId;
    author = widget.author;
    receiver = widget.receiver;
  }

  void uploadMessage() async {
    await FirebaseStorageDb.uploadMessageImage(
            File(widget.message.message), author!.userId!)
        .then((value) {
      if (value != 'failed') {
        widget.sendMessage(value, widget.replyMessage, widget.message.index);
      } else {
        if (mounted) {
          setState(() {
            widget.message.status = 2;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (!widget.isMe)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 10),
            child: CircleAvatar(
                radius: 20,
                backgroundColor: primaryColor,
                backgroundImage:
                    CachedNetworkImageProvider(widget.message.urlAvatar)),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SwipeTo(
                onRightSwipe: widget.isMe
                    ? widget.message.status == 1
                        ? () => widget.onSwipedMessage(widget.message)
                        : null
                    : null,
                onLeftSwipe: widget.isMe
                    ? null
                    : widget.message.status == 1
                        ? () => widget.onSwipedMessage(widget.message)
                        : null,
                child: buildMessage(context)),
            if (widget.showStatus || widget.message.status == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: buildStatus(),
              )
          ],
        ),
      ],
    );
  }

  Widget buildStatus() {
    if (widget.message.status == 0 && !sent) {
      return Text(
        'Sending...',
        style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12),
      );
    } else if (widget.message.status == 1) {
      return Text(
        'Sent ${DateFormat('hh:mm a').format(widget.message.createdAt)}',
        style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12),
      );
    } else if (widget.message.seen) {
      return Text(
        'Seen',
        style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12),
      );
    } else {
      return Text(
        'Send failed',
        style: TextStyle(color: Colors.red.withOpacity(0.6), fontSize: 12),
      );
    }
  }

  Widget buildMessage(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final typeId = widget.message.typeId ?? 0;

    if (typeId == 1) {
      return Container(
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: width * 3 / 4),
          child: Stack(children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: widget.message.message.contains('https://')
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ImagePreview(image: widget.message.message),
                              ));
                        },
                        child: Image(
                          image: CachedNetworkImageProvider(
                              widget.message.message),
                          width: double.infinity,
                          height: 500,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ImagePreview(image: widget.message.message),
                              ));
                        },
                        child: Image.file(File(widget.message.message),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            height: 500,
                            alignment: Alignment.topCenter),
                      )),
            if (widget.showButton && widget.message.status == 0)
              GestureDetector(
                onTap: () {
                  widget.cancelSend(widget.message.index!);
                },
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 5),
                  builder: (context, value, _) => Stack(children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: primaryColor.withOpacity(1.0 - value)),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: AlignmentDirectional.center,
                        child: Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Center(
                                  child: Container(
                                    width: 47,
                                    height: 47,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: plusColor.withOpacity(0.80)),
                                    child: const Icon(Icons.close,
                                        color: linkColor, size: 24),
                                  ),
                                ),
                                CircularProgressIndicator(
                                  value: value,
                                  valueColor:
                                      const AlwaysStoppedAnimation(linkColor),
                                  strokeWidth: 3,
                                  backgroundColor: userBgColor,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ]),
                  onEnd: () {
                    uploadMessage();
                    if (mounted) {
                      setState(() {
                        widget.showButton = false;
                      });
                    }
                  },
                ),
              ),
          ]));
    } else {
      final messageWidget = Text(widget.message.message);

      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        constraints: BoxConstraints(maxWidth: width * 3 / 4),
        decoration: BoxDecoration(
          color: widget.isMe ? primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: widget.message.replyMessage == null
            ? messageWidget
            : Column(
                crossAxisAlignment:
                    widget.isMe && widget.message.replyMessage == null
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: <Widget>[
                  buildReplyMessage(),
                  messageWidget,
                ],
              ),
      );
    }
  }

  Widget buildReplyMessage() {
    final replyMessage = widget.message.replyMessage;
    final isReplying = replyMessage != null;

    if (!isReplying) {
      return Container();
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: ReplyMessageWidget(message: replyMessage),
      );
    }
  }
}
