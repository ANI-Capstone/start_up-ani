import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/screens/components/basket_pages/active_orders.dart';
import 'package:ani_capstone/screens/components/basket_pages/basket_screen.dart';
import 'package:ani_capstone/screens/components/basket_pages/to_rate.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserBasket extends StatefulWidget {
  UserData userData;
  final Function(bool open) toggleBasket;
  final Function(int count, int index) setFeedBadge;
  UserBasket(
      {Key? key,
      required this.userData,
      required this.toggleBasket,
      required this.setFeedBadge})
      : super(key: key);

  @override
  _UserBasketState createState() => _UserBasketState();
}

class _UserBasketState extends State<UserBasket> {
  int tabIndex = 1;

  List<int> badgeCount = [0, 0, 0];

  void setBadgeCount(int count, int index) {
    if (mounted) {
      setState(() {
        badgeCount[index] = count;
        widget.setFeedBadge(count, index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  widget.toggleBasket(false);
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: linkColor,
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              const Text('BASKET',
                  style: TextStyle(
                    color: linkColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  )),
            ],
          ),
          backgroundColor: primaryColor,
          elevation: 0),
      backgroundColor: userBgColor,
      body: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          height: 80,
          decoration: const BoxDecoration(color: primaryColor),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            buildTabs(context, 'Your Basket', tabIndex, index: 0, onTap: () {
              if (mounted) {
                setState(() {
                  tabIndex = 0;
                });
              }
            }, icon: FontAwesomeIcons.bagShopping, count: badgeCount[0]),
            buildTabs(context, 'Active Orders', tabIndex, index: 1, onTap: () {
              if (mounted) {
                setState(() {
                  tabIndex = 1;
                });
              }
            }, icon: FontAwesomeIcons.boxOpen, count: badgeCount[1]),
            buildTabs(context, 'To Rate', tabIndex, index: 2, onTap: () {
              if (mounted) {
                setState(() {
                  tabIndex = 2;
                });
              }
            }, icon: FontAwesomeIcons.solidStar, count: badgeCount[2])
          ]),
        ),
        buildBasketPage(context, tabIndex)
      ]),
    );
  }

  Widget buildTabs(BuildContext context, String label, int tabIndex,
      {required VoidCallback onTap,
      required int index,
      required IconData icon,
      required int count}) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            width: size.width / 3,
            decoration: tabIndex == index
                ? BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: linkColor.withOpacity(0.8), width: 3)))
                : const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: primaryColor, width: 3))),
            child: Center(
                child: Column(
              children: [
                Badge(
                    // badgeColor: badgeColor,
                    badgeContent: Text(
                      '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    showBadge: count > 0,
                    elevation: 3,
                    position: BadgePosition.topEnd(top: -14, end: -12),
                    child: FaIcon(
                      icon,
                      size: 22,
                      color: tabIndex == index
                          ? linkColor
                          : linkColor.withOpacity(0.6),
                    )),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: tabIndex == index
                          ? linkColor
                          : linkColor.withOpacity(0.6)),
                ),
              ],
            ))),
      ),
    );
  }

  Widget buildBasketPage(BuildContext context, int tabIndex) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: IndexedStack(
        index: tabIndex,
        children: [
          BasketScreen(
            user: widget.userData,
            setBadgeCount: (int count, int index) {
              setBadgeCount(count, index);
            },
          ),
          ActiveOrders(
            user: widget.userData,
          ),
          ToRate(),
        ],
      ),
    );
  }
}
