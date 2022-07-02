import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/screens/components/farmer/user_feeds.dart';
import 'package:ani_capstone/screens/components/farmer/user_inbox.dart';
import 'package:ani_capstone/screens/components/farmer/user_notification.dart';
import 'package:ani_capstone/screens/components/farmer/user_post.dart';
import 'package:ani_capstone/screens/components/farmer/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserControl extends StatefulWidget {
  UserControl({Key? key}) : super(key: key);

  @override
  State<UserControl> createState() => _UserControlState();
}

class _UserControlState extends State<UserControl> {
  final user = FirebaseAuth.instance.currentUser!;

  int currentIndex = 0;

  final screens = [
    UserFeeds(),
    UserInbox(),
    UserPost(),
    UserNotificaiton(),
    UserProfile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.white,
          selectedItemColor: linkColor,
          backgroundColor: primaryColor,
          items: const [
            BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.house), label: 'Feed'),
            BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.solidMessage), label: 'Inbox'),
            BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.circlePlus), label: 'Post'),
            BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.solidBell),
                label: 'Notification'),
            BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.solidUser), label: 'Profile'),
          ]),
    );
  }
}
