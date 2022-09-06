import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/screens/components/user/user_feeds.dart';
import 'package:ani_capstone/screens/components/user/user_inbox.dart';
import 'package:ani_capstone/screens/components/user/user_notification.dart';
import 'package:ani_capstone/screens/components/user/user_post.dart';
import 'package:ani_capstone/screens/components/user/user_profile.dart';
import 'package:ani_capstone/screens/user_type_select.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserControl extends StatefulWidget {
  const UserControl({Key? key}) : super(key: key);

  @override
  State<UserControl> createState() => _UserControlState();
}

class _UserControlState extends State<UserControl> {
  UserData? _userData;
  var user;

  @override
  void initState() {
    super.initState();

    user = FirebaseAuth.instance.currentUser;

    FirebaseFirestoreDb.getUser(context, userId: user.uid);

    if (user == null) {
      FirebaseAuth.instance.signOut();
    }
  }

  Future getUserData() async {
    return FirebaseFirestoreDb.getUser(context, userId: user.uid)
        .then((value) => {_userData = value});
  }

  Widget checkUserType() {
    final userType = _userData?.userTypeId;
    if (userType != 0) {
      return UserViewScreen(userType: userType);
    }

    return UserSelect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getUserData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ShoWInfo.errorAlert(context, snapshot.error.toString(), 5);
          } else {
            return checkUserType();
          }
        },
      ),
    );
  }
}

class UserViewScreen extends StatefulWidget {
  int? userType;
  UserViewScreen({Key? key, this.userType}) : super(key: key);

  @override
  State<UserViewScreen> createState() => _UserViewScreenState();
}

class _UserViewScreenState extends State<UserViewScreen> {
  int currentIndex = 1;
  int? userType;
  var screens;
  var navItems;

  @override
  void initState() {
    super.initState();

    userType = widget.userType as int;

    screens = userType == 1
        ? [
            UserFeeds(),
            UserInbox(),
            UserPost(),
            UserNotificaiton(),
            UserProfile()
          ]
        : [UserFeeds(), UserInbox(), UserNotificaiton(), UserProfile()];

    navItems = userType == 1
        ? [
            const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.house), label: 'Feed'),
            const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.solidMessage), label: 'Inbox'),
            const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.circlePlus), label: 'Post'),
            const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.solidBell),
                label: 'Notification'),
            const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.solidUser), label: 'Profile'),
          ]
        : [
            const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.house), label: 'Feed'),
            const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.solidMessage), label: 'Inbox'),
            const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.solidBell),
                label: 'Notification'),
            const BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.solidUser), label: 'Profile'),
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: IndexedStack(index: currentIndex, children: screens)),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.white,
          selectedItemColor: linkColor,
          backgroundColor: primaryColor,
          items: navItems),
    );
  }
}
