import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatScreen extends StatefulWidget {
  List<Message>? messages;
  User? user;

  ChatScreen({Key? key, this.user, this.messages}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: linkColor),
        backgroundColor: primaryColor,
        toolbarHeight: 60,
        elevation: 0,
        title: Transform.translate(
          offset: const Offset(-24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      'https://i.ibb.co/StGZh5F/20180411134321-zuck.webp')),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Mark Zuckmyberd',
                    style: TextStyle(
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
      body: Container(
        child: Column(children: [
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                  floatingLabelAlignment: FloatingLabelAlignment.center,
                  contentPadding: EdgeInsets.all(12),
                  hintText: 'Type your message',
                  suffixIcon: FaIcon(
                    FontAwesomeIcons.solidPaperPlane,
                    size: 20,
                  )),
            ),
          )
        ]),
      ),
    );
  }
}
