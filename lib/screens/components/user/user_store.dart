import 'dart:async';

import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/order.dart';
import 'package:ani_capstone/screens/components/basket_pages/active_orders.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserStore extends StatefulWidget {
  UserData userData;
  final Function(bool open) toggleBasket;
  final Function(int count, int index) setFeedBadge;
  UserStore(
      {Key? key,
      required this.userData,
      required this.toggleBasket,
      required this.setFeedBadge})
      : super(key: key);

  @override
  _UserStoreState createState() => _UserStoreState();
}

class _UserStoreState extends State<UserStore> {
  int tabIndex = 0;

  List<int> badgeCount = [0, 0, 0];

  List<List<Order>> order = [[], [], []];

  List<int> fetchState = [0, 0, 0];
  late StreamSubscription listener;

  @override
  void initState() {
    super.initState();

    fetchOrders();
    orderListener();
  }

  @override
  void dispose() {
    super.dispose();

    listener.cancel();
  }

  void setBadgeCount(int count, int index) {
    if (mounted) {
      setState(() {
        badgeCount[index] = count;
        widget.setFeedBadge(count, index);
      });
    }
  }

  void orderListener() {
    final orderRef = ProductPost.orderStream(
        userId: widget.userData.id!, userType: widget.userData.userTypeId);

    listener = orderRef.listen((event) async {
      fetchOrders();
    });
  }

  void fetchOrders() async {
    ProductPost.getOrders(
            userId: widget.userData.id!, userType: widget.userData.userTypeId)
        .then((orders) {
      order.clear();

      order = [[], [], []];

      if (orders.isNotEmpty) {
        for (var order in orders) {
          if (order.status == 0) {
            this.order[0].add(order);
          } else if (order.status == 1) {
            this.order[1].add(order);
          } else {
            this.order[2].add(order);
          }
        }

        for (int i = 0; i < order.length; i++) {
          if (order[i].isNotEmpty) {
            if (mounted) {
              setState(() {
                fetchState[i] = 1;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                fetchState[i] = 2;
              });
            }
          }

          setBadgeCount(order[i].length, i);
        }
      } else {
        for (int i = 0; i < order.length; i++) {
          if (mounted) {
            setState(() {
              fetchState[i] = 2;
            });
          }
        }
      }
    }).onError((error, stackTrace) {
      for (int i = 0; i < order.length; i++) {
        if (mounted) {
          setState(() {
            fetchState[i] = -1;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            buildTabs(context, 'Orders', tabIndex, index: 0, onTap: () {
              if (mounted) {
                setState(() {
                  tabIndex = 0;
                });
              }
            }, icon: FontAwesomeIcons.store, count: badgeCount[0]),
            buildTabs(context, 'To Pick-up', tabIndex, index: 1, onTap: () {
              if (mounted) {
                setState(() {
                  tabIndex = 1;
                });
              }
            }, icon: FontAwesomeIcons.boxOpen, count: badgeCount[1]),
            buildTabs(context, 'Sold', tabIndex, index: 2, onTap: () {
              if (mounted) {
                setState(() {
                  tabIndex = 2;
                });
              }
            }, icon: FontAwesomeIcons.moneyCheckDollar, count: badgeCount[2])
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
          ActiveOrders(
            user: widget.userData,
            orderStatus: 0,
            order: fetchState[0] == 0 ? [] : order[0],
            fetchState: fetchState[0],
          ),
          ActiveOrders(
              user: widget.userData,
              orderStatus: 1,
              order: fetchState[1] == 0 ? [] : order[1],
              fetchState: fetchState[1]),
          ActiveOrders(
              user: widget.userData,
              orderStatus: 2,
              order: fetchState[2] == 0 ? [] : order[2],
              fetchState: fetchState[2]),
        ],
      ),
    );
  }
}
