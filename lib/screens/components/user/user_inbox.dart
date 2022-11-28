import 'dart:async';

import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/api/notification_api.dart';
import 'package:ani_capstone/models/chat.dart';
import 'package:ani_capstone/models/notification.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/components/chat_page/chat_box.dart';
import 'package:ani_capstone/screens/components/chat_page/chat_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants.dart';
import '../widgets/pull_refresh.dart';

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
  late StreamSubscription listener;
  late final NotificationApi notificationService;
  var notifData;

  @override
  void initState() {
    super.initState();

    notificationService = NotificationApi();
    notificationService.initializePlatformNotifications();

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
    listener.cancel();
  }

  Future loadChats() async {
    if (AccountControl.isUserLoggedIn()) {
      await FirebaseMessageApi.getChats(widget.user.id!).then((data) {
        if (mounted) {
          setState(() => chats = data);
        }

        int unreadCount = 0;
        final userId = AccountControl.getUserId();

        for (var chat in data) {
          if (chat.message.userId != userId && !chat.message.seen) {
            unreadCount += 1;
          }
        }

        NotificationApi.unReadMessages = unreadCount;
      });
    } else {
      timer?.cancel();
      listener.cancel();
    }
  }

  void chatListener() async {
    final chatRef = FirebaseMessageApi.chatStream(widget.user.id!);

    listener = chatRef.listen((event) async {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final messageNotif = MessageNotification.fromJson(change.doc.data());

          if (AccountControl.getUserId() != messageNotif.contactId) {
            await notificationService.showLocalNotification(
                id: 0,
                title: messageNotif.title,
                body: messageNotif.body,
                payload: messageNotif.payload);
          }
        }
      }
      loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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
              SizedBox(height: height * 0.6, child: buildList())
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
        // FirebaseMessageApi.readMessage(
        //     AccountControl.getUserId(), chat.contact.userId!, chat.message);

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatBox(
                    receiver: chat.contact,
                    author: widget.user,
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
                builder: (context) => ChatBox(
                      receiver: user,
                      author: widget.user,
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
