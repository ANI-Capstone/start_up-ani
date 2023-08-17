import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/screens/components/chat_page/reply_widget.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class NewMessageWidget extends StatefulWidget {
  final FocusNode focusNode;
  final Message? replyMessage;
  final VoidCallback onCancelReply;
  final Function(String message, Message? replyMessage) sendImage;
  final Function(String message, Message? replyMessage) sendText;

  const NewMessageWidget({
    required this.focusNode,
    this.replyMessage,
    required this.onCancelReply,
    required this.sendImage,
    required this.sendText,
    Key? key,
  }) : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  String message = '';

  final ImagePicker _picker = ImagePicker();

  static const inputTopRadius = Radius.circular(12);
  static const inputBottomRadius = Radius.circular(24);

  void sendMessage() async {
    widget.focusNode.requestFocus();
    widget.onCancelReply();
    _controller.clear();

    widget.sendText(message, widget.replyMessage);
  }

  @override
  Widget build(BuildContext context) {
    final isReplying = widget.replyMessage != null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 10, bottom: 10),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: ((builder) => bottomSheet()),
                );
              },
              child: const FaIcon(
                Icons.camera_alt_rounded,
                size: 28,
                color: primaryColor,
              ),
            ),
          ),
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
                  style: const TextStyle(decoration: TextDecoration.none),
                  decoration: InputDecoration(
                    isDense: true,
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
              message.trim().isEmpty ? null : sendMessage();
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Container(
                height: 40,
                width: 40,
                padding: const EdgeInsets.only(
                    left: 10, top: 10, bottom: 10, right: 14),
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
          ),
          const SizedBox(width: 5)
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            "Send a photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.camera, color: linkColor),
              onPressed: () {
                Navigator.pop(context);
                takePhoto(ImageSource.camera);
              },
              label: const Text("Camera", style: TextStyle(color: textColor)),
            ),
            const SizedBox(
              width: 20,
            ),
            TextButton.icon(
              icon: const Icon(Icons.image, color: linkColor),
              onPressed: () {
                Navigator.pop(context);
                takePhoto(ImageSource.gallery);
              },
              label: const Text("Gallery", style: TextStyle(color: textColor)),
            ),
          ])
        ],
      ),
    );
  }

  Future takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) return;

    final selectedImage = pickedFile.path;

    if (mounted) {
      setState(() {
        widget.sendImage(selectedImage, widget.replyMessage);
      });
    }

    // FirebaseStorageDb.uploadImage(context,
    //         userId: authID.toString(), path: 'image-url', imageFile: tempImage)
    //     .then((value) => {
    //           setState(() {
    //             if (value != null) {
    //               _imageFile = tempImage;
    //               photoURL = value;
    //             }
    //           })
    //         });
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
