import 'dart:async';

import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/models/chat.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/components/chat_page/chat_card.dart';
import 'package:ani_capstone/screens/components/chat_page/chat_screen.dart';
import 'package:ani_capstone/screens/user_control.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants.dart';
import '../pull_refresh.dart';

class UserInbox extends StatefulWidget {
  UserData user;

  UserInbox({Key? key, required this.user}) : super(key: key);

  @override
  State<UserInbox> createState() => _UserInboxState();
}

class _UserInboxState extends State<UserInbox> {
  User? author;
  Timer? timer;
  List<Chat> chats = [];

  @override
  void initState() {
    super.initState();
    author = User(
        name: widget.user.name,
        userId: widget.user.id,
        photoUrl: widget.user.photoUrl!);

    chatListener();
    loadChats();

    timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        setState(() {
          loadChats();
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Future loadChats() async {
    await FirebaseMessageApi.getChats(widget.user.id!).then((data) {
      if (mounted) {
        setState(() => chats = data);
      }
    });
  }

  void chatListener() async {
    Stream chatStream = FirebaseMessageApi.chatStream(widget.user.id!);

    chatStream.listen((snapshot) {
      loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('INBOX',
                  style:
                      TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
              Icon(FontAwesomeIcons.magnifyingGlass, size: 20, color: linkColor)
            ],
          ),
          backgroundColor: primaryColor,
          elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.only(top: 15),
                child: StreamBuilder<List<User>>(
                    stream: FirebaseMessageApi.getUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong.');
                      } else if (snapshot.hasData) {
                        final users = snapshot.data!;
                        return SizedBox(
                          height: 90,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: users.map(buildUser).toList()),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: SizedBox(
                  child: Text(
                    'Messages',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),
              buildList()
            ]),
          ),
        ),
      ),
    );
  }

  Widget buildList() => chats.isEmpty
      ? const Center(child: Text('No chats'))
      : RefreshWidget(
          onRefresh: loadChats,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return buildChat(chats[index]);
              }),
        );

  Widget buildChat(Chat chat) => GestureDetector(
      onTap: () {
        FirebaseMessageApi.readMessage(
            AccountControl.getUserId(), chat.contact.userId!, chat.message);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(
                    receiver: chat.contact,
                    author: User(
                        name: widget.user.name,
                        userId: widget.user.id,
                        photoUrl: widget.user.photoUrl!),
                  )),
        );
      },
      child: ChatCard(chat: chat));

  Widget buildUser(User user) => Container(
      margin: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      receiver: user,
                      author: User(
                          name: widget.user.name,
                          userId: widget.user.id,
                          photoUrl: widget.user.photoUrl!),
                    )),
          );
        },
        child: SizedBox(
          width: 70,
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              const SizedBox(height: 5),
              Text(
                user.name,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  color: linkColor,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ));
}
