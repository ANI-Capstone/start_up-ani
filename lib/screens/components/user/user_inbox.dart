import 'dart:async';

import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/api/notification_api.dart';
import 'package:ani_capstone/models/chat.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/components/chat_page/chat_box.dart';
import 'package:ani_capstone/screens/components/chat_page/chat_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:search_page/search_page.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../constants.dart';
import '../widgets/pull_refresh.dart';

class UserInbox extends StatefulWidget {
  UserData user;
  Function(int count) setBadge;

  UserInbox({Key? key, required this.user, required this.setBadge})
      : super(key: key);

  @override
  State<UserInbox> createState() => _UserInboxState();
}

class _UserInboxState extends State<UserInbox> {
  User? author;
  Timer? timer;
  List<Chat> chats = [];
  late final NotificationApi notificationService;
  late StreamSubscription listener;

  List<User> users = [];

  @override
  void initState() {
    super.initState();

    notificationService = NotificationApi();
    notificationService.initializePlatformNotifications();

    author = User(
        name: widget.user.name,
        userId: widget.user.id,
        photoUrl: widget.user.photoUrl!);

    loadChats();
    chatListener();
  }

  @override
  void dispose() {
    super.dispose();
    listener.cancel();
  }

  Future loadChats() async {
    if (AccountControl.isUserLoggedIn()) {
      await FirebaseMessageApi.getChats(widget.user.id!).then((data) {
        int unreadCount = 0;
        final userId = AccountControl.getUserId();

        for (var chat in data) {
          if (chat.message.userId != userId && !chat.message.seen) {
            unreadCount += 1;

            final now = DateTime.now().subtract(const Duration(seconds: 10));

            if (chat.message.createdAt.isAfter(now) ||
                chat.message.createdAt.isAtSameMomentAs(DateTime.now())) {
              newChatNotifier(chat);
            }
          }
        }

        if (mounted) {
          setState(() {
            chats = data;
          });
        }

        setState(() {
          widget.setBadge(unreadCount);
        });
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
      });
    } else {
      timer?.cancel();
    }
  }

  void newChatNotifier(Chat chat) async {
    await notificationService.showLocalNotification(
        id: 0,
        title: chat.contact.name,
        body: chat.message.typeId == 1 ? 'Sent a photo.' : chat.message.message,
        payload: chat.chatPathId);
  }

  void chatListener() async {
    final chatRef = FirebaseMessageApi.chatStream(widget.user.id!);

    listener = chatRef.listen((event) async {
      loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return VisibilityDetector(
      key: const Key('inbox-screen'),
      onVisibilityChanged: (info) {
        if ((info.visibleFraction * 100) == 100) {
          loadChats();
        }
      },
      child: Scaffold(
        backgroundColor: userBgColor,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('INBOX',
                style:
                    TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: SearchPage<User>(
                        barTheme: ThemeData(
                            primarySwatch: Colors.green,
                            primaryColor: primaryColor,
                            fontFamily: 'Roboto',
                            appBarTheme: const AppBarTheme(
                                backgroundColor: primaryColor,
                                elevation: 0,
                                iconTheme: IconThemeData(color: linkColor))),
                        items: users,
                        searchLabel: 'Search user',
                        suggestion: const Center(
                          child: Text('Filter user by name'),
                        ),
                        failure: const Center(
                          child: Text('No user found.'),
                        ),
                        filter: (user) => [user.name],
                        builder: (user) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
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
                            child: ListTile(
                              leading: CircleAvatar(
                                  backgroundColor: primaryColor,
                                  backgroundImage:
                                      CachedNetworkImageProvider(user.photoUrl),
                                  radius: 24),
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                    color: linkColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Icon(FontAwesomeIcons.magnifyingGlass,
                      size: 20, color: linkColor),
                ),
              )
            ],
            backgroundColor: primaryColor,
            elevation: 0),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 15),
                      child: StreamBuilder<List<User>>(
                          stream: FirebaseMessageApi.getUsers(
                              userId: widget.user.id!),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Something went wrong.');
                            } else if (snapshot.hasData) {
                              users = snapshot.data!;
                              return SizedBox(
                                height: 90,
                                child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: users.map(buildUser).toList()),
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
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
                backgroundColor: primaryColor,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
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
