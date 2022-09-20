import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/chat_page/reply_widget.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewMessageWidget extends StatefulWidget {
  final FocusNode focusNode;
  final Message? replyMessage;
  final VoidCallback onCancelReply;
  final String chatPathId;
  final User author;
  final User receiver;

  const NewMessageWidget({
    required this.focusNode,
    this.replyMessage,
    required this.onCancelReply,
    required this.chatPathId,
    required this.author,
    required this.receiver,
    Key? key,
  }) : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  String message = '';
  String? chatPathId;
  User? author;
  User? receiver;
  Message? replyMessage;

  @override
  void initState() {
    super.initState();
    chatPathId = widget.chatPathId;
    replyMessage = widget.replyMessage;
    author = widget.author;
    receiver = widget.receiver;
  }

  static const inputTopRadius = Radius.circular(12);
  static const inputBottomRadius = Radius.circular(24);

  void sendMessage(String type) async {
    FocusScope.of(context).unfocus();
    widget.onCancelReply();

    try {
      await FirebaseMessageApi.sendMessage(
          chatPathId!, message, author!, receiver!, type,
          replyMessage: replyMessage);
    } catch (e) {
      null;
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isReplying = widget.replyMessage != null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: [
                if (isReplying) buildReply(),
                TextField(
                  focusNode: widget.focusNode,
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.only(
                        topLeft: isReplying ? Radius.zero : inputBottomRadius,
                        topRight: isReplying ? Radius.zero : inputBottomRadius,
                        bottomLeft: inputBottomRadius,
                        bottomRight: inputBottomRadius,
                      ),
                    ),
                  ),
                  onChanged: (value) => setState(() {
                    message = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              message.trim().isEmpty ? null : sendMessage('TEXT');
            },
            child: Container(
              height: 40,
              width: 40,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
              child: const FaIcon(
                FontAwesomeIcons.solidPaperPlane,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 5)
        ],
      ),
    );
  }

  Widget buildReply() => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: inputTopRadius,
            topRight: inputTopRadius,
          ),
        ),
        child: ReplyMessageWidget(
          message: widget.replyMessage!,
          onCancelReply: widget.onCancelReply,
        ),
      );
}
