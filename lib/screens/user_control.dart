import 'dart:async';

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/components/user/user_basket.dart';
import 'package:ani_capstone/screens/components/user/user_feeds.dart';
import 'package:ani_capstone/screens/components/user/user_inbox.dart';
import 'package:ani_capstone/screens/components/user/user_notification.dart';
import 'package:ani_capstone/screens/components/user/user_post.dart';
import 'package:ani_capstone/screens/components/user/user_profile.dart';
import 'package:ani_capstone/screens/components/user/user_store.dart';
import 'package:ani_capstone/screens/user_type_select.dart';
import 'package:badges/badges.dart' as badges;
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
  int currentIndex = 4;
  int? userType;
  UserData? user;

  var showMessageBadge = false;
  var showBottomNavigation = true;

  List<int> badgeCount = [0, 0, 0];
  List<int> eachCount = [0, 0, 0];

  String messageBadge = "3";
  late StreamSubscription<bool> keyboardSubscription;

  FaIcon homeNav = const FaIcon(FontAwesomeIcons.house);
  FaIcon inboxNav = const FaIcon(FontAwesomeIcons.solidMessage);
  FaIcon postNav = const FaIcon(FontAwesomeIcons.circlePlus);
  FaIcon reviewNav = const FaIcon(FontAwesomeIcons.bagShopping);
  FaIcon notifNav = const FaIcon(FontAwesomeIcons.solidBell);
  FaIcon userNav = const FaIcon(FontAwesomeIcons.solidUser);

  int exitApp = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    userType = widget.userType!;
    user = widget.user;

    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          showBottomNavigation = !visible;
        });
      }
    });

    _timer = Timer(const Duration(seconds: 0), () {});
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();

    _timer.cancel();
  }

  void getUserData() async {
    AccountControl.accountCheck(context).then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });
  }

  void hideNavigationBar(bool hide) {
    if (mounted) {
      setState(() {
        showBottomNavigation = !hide;
      });
    }
  }

  void setMessageBadge(int count) {
    if (mounted) {
      setState(() {
        badgeCount[1] = count;
      });
    }
  }

  void setNotifBadge(int count) {
    if (mounted) {
      setState(() {
        badgeCount[2] = count;
      });
    }
  }

  void toggleBasket(open) {
    if (mounted) {
      setState(() {
        open == false ? currentIndex = 0 : currentIndex = 5;
      });
    }
  }

  void setFeedBadge(int count, int index) {
    eachCount[index] = count;

    if (mounted) {
      int sum = 0;
      for (int i = 0; i < 3; i++) {
        sum += eachCount[i];
      }
      badgeCount[0] = 0;

      setState(() {
        badgeCount[0] = sum;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (exitApp == 0) ShoWInfo.showToast('Try again to exit the app.', 3);

        exitApp++;

        if (!_timer.isActive) {
          _timer = Timer(const Duration(seconds: 5), () async {
            exitApp = 0;
          });
        }
        return exitApp == 2;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
            color: Colors.white,
            child: IndexedStack(index: currentIndex, children: [
              UserFeed(
                user: user!,
                openBasket: (open) {
                  toggleBasket(open);
                },
                badgeCount: badgeCount[0],
              ),
              UserInbox(
                user: user!,
                setBadge: (int count) {
                  setMessageBadge(count);
                },
              ),
              userType == 1
                  ? UserPost(user: user!)
                  : UserBasket(
                      userData: user!,
                      toggleBasket: (open) {
                        toggleBasket(open);
                      },
                      setFeedBadge: (int count, int index) {
                        setFeedBadge(count, index);
                      }),
              UserNotificaiton(
                user: user!,
                setBadge: (int count) {
                  setNotifBadge(count);
                },
              ),
              UserProfile(
                user: user!,
                getUserData: () {
                  getUserData();
                },
              ),
              user!.userTypeId == 1
                  ? UserStore(
                      userData: user!,
                      toggleBasket: (open) {
                        toggleBasket(open);
                      },
                      setFeedBadge: (int count, int index) {
                        setFeedBadge(count, index);
                      },
                    )
                  : UserBasket(
                      userData: user!,
                      toggleBasket: (open) {
                        toggleBasket(open);
                      },
                      setFeedBadge: (int count, int index) {
                        setFeedBadge(count, index);
                      })
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
                  index: currentIndex > 4 ? 0 : currentIndex,
                  onTap: (index) {
                    FocusManager.instance.primaryFocus?.unfocus();
                    setState(() => currentIndex = index);
                  },
                  items: [
                    homeNav,
                    badges.Badge(
                      badgeContent: Text(
                        '${badgeCount[1]}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      showBadge: badgeCount[1] > 0,
       
                      position: badges.BadgePosition.topEnd(top: -14, end: -12),
                      child: inboxNav,
                    ),
                    userType == 1 ? postNav : reviewNav,
                    badges.Badge(
                        badgeContent: Text(
                          '${badgeCount[2]}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        showBadge: badgeCount[2] > 0,
               
                        position: badges.BadgePosition.topEnd(top: -14, end: -12),
                        child: notifNav),
                    userNav
                  ],
                ),
              ),
      ),
    );
  }
}
