import 'dart:async';

import 'package:ani_capstone/api/account_api.dart';
import 'package:ani_capstone/api/fcm_notif_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/components/user/user_basket.dart';
import 'package:ani_capstone/screens/components/user/user_feeds.dart';
import 'package:ani_capstone/screens/components/user/user_inbox.dart';
import 'package:ani_capstone/screens/components/user/user_map.dart';
import 'package:ani_capstone/screens/components/user/user_post.dart';
import 'package:ani_capstone/screens/components/user/user_profile.dart';
import 'package:ani_capstone/screens/components/user/user_store.dart';
import 'package:ani_capstone/screens/users/establishments/user_create_order.dart';
import 'package:ani_capstone/screens/users/establishments/user_es_basket.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key, required this.user}) : super(key: key);

  final UserData user;

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int currentIndex = 2;
  int? userType;
  UserData? user;

  var showMessageBadge = false;
  var showBottomNavigation = true;

  List<int> badgeCount = [0, 0, 0];
  List<int> eachCount = [0, 0, 0];

  List<Product> addedProducts = [];

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

    notifInit();
    _timer = Timer(const Duration(seconds: 0), () {});
  }

  void updateAddedProducts(List<Product> products) {
    setState(() {
      addedProducts = products;
    });
  }

  Future<void> notifInit() async {
    await NotifAPI.initNotification();

    if (widget.user.fcmToken == null) {
      final fcmToken = await NotifAPI.firebaseMessaging.getToken();

      AccountApi.setFcmToken(userId: user!.id!, fcmToken: fcmToken!)
          .then((value) {
        setState(() {
          widget.user.fcmToken = fcmToken;
        });
      });
    }
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
    NotifAPI.notifListener.cancel();

    _timer.cancel();
  }

  void getUserData() async {
    AccountControl.accountCheck(context).then((value) async {
      if (mounted) {
        if (value) {
          setState(() {
            user = value;
          });
        }
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

  Widget _userBasket() {
    return UserEsBasket(
      user: user!,
      updateAddedProducts: (products) {
        updateAddedProducts(products);
      },
      setFeedBadge: ((count, index) {
        setFeedBadge(count, index);
      }),
      toggleBasket: ((open) {
        toggleBasket(open);
      }),
    );
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
            child: IndexedStack(index: currentIndex, children: [
          UserFeed(
            user: user!,
            openBasket: (open) {
              toggleBasket(open);
            },
            badgeCount: badgeCount[0],
            addedProducts: addedProducts,
          ),
          UserInbox(
            user: user!,
            setBadge: (int count) {
              setMessageBadge(count);
            },
          ),
          _userBasket(),
          UserMap(),
          UserProfile(
            user: user!,
            getUserData: () {
              getUserData();
            },
          ),
          _userBasket()
        ])),
        bottomNavigationBar: !showBottomNavigation
            ? null
            : Theme(
                data: Theme.of(context)
                    .copyWith(iconTheme: const IconThemeData(color: linkColor)),
                child: CurvedNavigationBar(
                  color: primaryColor,
                  backgroundColor: Colors.white,
                  buttonBackgroundColor: Colors.transparent,
                  height: 50,
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
                    FaIcon(FontAwesomeIcons.bagShopping),
                    badges.Badge(
                        badgeContent: Text(
                          '${badgeCount[2]}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        showBadge: badgeCount[2] > 0,
                        position:
                            badges.BadgePosition.topEnd(top: -14, end: -12),
                        child: notifNav),
                    userNav
                  ],
                ),
              ),
      ),
    );
  }
}
