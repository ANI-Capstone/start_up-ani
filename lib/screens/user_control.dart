import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/components/user/user_feeds.dart';
import 'package:ani_capstone/screens/components/user/user_inbox.dart';
import 'package:ani_capstone/screens/components/user/user_notification.dart';
import 'package:ani_capstone/screens/components/user/user_post.dart';
import 'package:ani_capstone/screens/components/user/user_profile.dart';
import 'package:ani_capstone/screens/user_type_select.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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

  Future getUserData() async {
    return AccountControl.accountCheck(context);
  }

  Widget checkUserType() {
    final userType = _userData?.userTypeId;
    if (userType != 0) {
      return UserViewScreen(
        userType: userType,
        user: _userData,
      );
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
          } else if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            _userData = snapshot.data;
            return checkUserType();
          }
        },
      ),
    );
  }
}

class UserViewScreen extends StatefulWidget {
  int? userType;
  UserData? user;
  UserViewScreen({Key? key, this.userType, this.user}) : super(key: key);

  @override
  State<UserViewScreen> createState() => _UserViewScreenState();
}

class _UserViewScreenState extends State<UserViewScreen> {
  int currentIndex = 1;
  int? userType;
  UserData? user;
  var screens;
  var navItems;

  @override
  void initState() {
    super.initState();

    userType = widget.userType as int;
    user = widget.user;

    screens = userType == 1
        ? [
            UserFeeds(),
            UserInbox(user: user!),
            UserPost(),
            UserNotificaiton(),
            UserProfile()
          ]
        : [
            UserFeeds(),
            UserInbox(user: user!),
            UserNotificaiton(),
            UserProfile()
          ];

    navItems = userType == 1
        ? [
            const FaIcon(FontAwesomeIcons.house),
            const FaIcon(FontAwesomeIcons.solidMessage),
            const FaIcon(FontAwesomeIcons.circlePlus),
            const FaIcon(FontAwesomeIcons.solidBell),
            const FaIcon(FontAwesomeIcons.solidUser),
          ]
        : [
            const FaIcon(FontAwesomeIcons.house),
            const FaIcon(FontAwesomeIcons.solidMessage),
            const FaIcon(FontAwesomeIcons.solidBell),
            const FaIcon(FontAwesomeIcons.solidUser),
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
          color: Colors.white,
          child: IndexedStack(index: currentIndex, children: screens)),
      bottomNavigationBar: Theme(
        data: Theme.of(context)
            .copyWith(iconTheme: const IconThemeData(color: linkColor)),
        child: CurvedNavigationBar(
          color: primaryColor,
          backgroundColor: Colors.transparent,
          buttonBackgroundColor: Colors.transparent,
          height: 66,
          index: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          items: navItems,
        ),
      ),
    );
  }
}
