import 'dart:async';

import 'package:ani_capstone/api/notification_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/components/user/user_feeds.dart';
import 'package:ani_capstone/screens/components/user/user_inbox.dart';
import 'package:ani_capstone/screens/components/user/user_notification.dart';
import 'package:ani_capstone/screens/components/user/user_post.dart';
import 'package:ani_capstone/screens/components/user/user_profile.dart';
import 'package:ani_capstone/screens/components/user/user_reviews.dart';
import 'package:ani_capstone/screens/user_type_select.dart';
import 'package:badges/badges.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

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

  var showMessageBadge = false;
  var showBottomNavigation = true;

  String messageBadge = "3";
  late StreamSubscription<bool> keyboardSubscription;

  FaIcon homeNav = const FaIcon(FontAwesomeIcons.house);
  FaIcon inboxNav = const FaIcon(FontAwesomeIcons.solidMessage);
  FaIcon postNav = const FaIcon(FontAwesomeIcons.circlePlus);
  FaIcon reviewNav = const FaIcon(FontAwesomeIcons.solidStar);
  FaIcon notifNav = const FaIcon(FontAwesomeIcons.solidBell);
  FaIcon userNav = const FaIcon(FontAwesomeIcons.solidUser);

  @override
  void initState() {
    super.initState();

    userType = widget.userType!;
    user = widget.user;

    unReadListener();

    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          showBottomNavigation = !visible;
        });
      }
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  void unReadListener() async {
    NotificationApi.unreadMessages().listen((event) {
      if (event > 0) {
        setState(() {
          showMessageBadge = true;
          messageBadge = event.toString();
        });
      } else {
        setState(() {
          showMessageBadge = false;
          messageBadge = event.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          color: Colors.white,
          child: IndexedStack(index: currentIndex, children: [
            UserFeed(user: user!),
            UserInbox(user: user!),
            userType == 1 ? UserPost(user: user!) : const UserReviews(),
            UserNotificaiton(),
            UserProfile()
          ])),
      bottomNavigationBar: !showBottomNavigation
          ? null
          : Theme(
              data: Theme.of(context)
                  .copyWith(iconTheme: const IconThemeData(color: linkColor)),
              child: CurvedNavigationBar(
                color: primaryColor,
                backgroundColor: Colors.transparent,
                buttonBackgroundColor: Colors.transparent,
                height: 55,
                index: currentIndex,
                onTap: (index) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() => currentIndex = index);
                },
                items: [
                  homeNav,
                  Badge(
                    // badgeColor: badgeColor,
                    badgeContent: Text(
                      messageBadge,
                      style: const TextStyle(color: Colors.white),
                    ),
                    showBadge: showMessageBadge,
                    elevation: 3,
                    position: BadgePosition.topEnd(top: -14, end: -12),
                    child: inboxNav,
                  ),
                  userType == 1 ? postNav : reviewNav,
                  notifNav,
                  userNav
                ],
              ),
            ),
    );
  }
}
