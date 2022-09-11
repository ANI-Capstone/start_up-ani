import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/chat_page/reply_widget.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewMessageWidget extends StatefulWidget {
  final FocusNode focusNode;
  final User user;
  final Message? replyMessage;
  final VoidCallback onCancelReply;
  final String chatPathId;

  const NewMessageWidget({
    required this.focusNode,
    required this.user,
    this.replyMessage,
    required this.onCancelReply,
    required this.chatPathId,
    Key? key,
  }) : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  String message = '';
  String? chatPathId;
  Message? replyMessage;
  User? user;

  @override
  void initState() {
    super.initState();
    chatPathId = widget.chatPathId;
    replyMessage = widget.replyMessage;
    user = widget.user;
  }

  static final inputTopRadius = Radius.circular(12);
  static final inputBottomRadius = Radius.circular(24);

  void sendMessage() async {
    FocusScope.of(context).unfocus();
    widget.onCancelReply();

    try {
      await FirebaseMessageApi.sendMessage(chatPathId!, message, user!,
          replyMessage: replyMessage);
    } catch (e) {
      print(e.toString());
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isReplying = widget.replyMessage != null;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
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
          SizedBox(width: 10),
          GestureDetector(
            onTap: message.trim().isEmpty ? null : sendMessage,
            child: Container(
              height: 40,
              width: 40,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
              child: FaIcon(
                FontAwesomeIcons.solidPaperPlane,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 5)
        ],
      ),
    );
  }

  Widget buildReply() => Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.only(
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
