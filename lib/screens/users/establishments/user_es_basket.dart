import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/screens/users/establishments/user_components/user_active_orders/estab_active_orders.dart';
import 'package:ani_capstone/screens/users/establishments/user_components/user_basket/estab_basket.dart';
import 'package:ani_capstone/screens/users/establishments/user_components/user_orders/estab_orders.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;

class UserEsBasket extends StatefulWidget {
  const UserEsBasket(
      {Key? key,
      required this.user,
      required this.updateAddedProducts,
      required this.setFeedBadge,
      required this.toggleBasket})
      : super(key: key);

  final UserData user;
  final Function(List<Product> products) updateAddedProducts;
  final Function(bool open) toggleBasket;
  final Function(int count, int index) setFeedBadge;

  @override
  _UserEsBasketState createState() => _UserEsBasketState();
}

class _UserEsBasketState extends State<UserEsBasket> {
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
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: userBgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  color: primaryColor,
                  child: Row(
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
                            fontSize: 20,
                            color: linkColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                          )),
                    ],
                  ),
                ),
                Container(
                  height: 55,
                  decoration: const BoxDecoration(color: primaryColor),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildTabs(context, 'Your Basket', tabIndex, index: 0,
                            onTap: () {
                          if (mounted) {
                            setState(() {
                              tabIndex = 0;
                            });
                          }
                        },
                            icon: FontAwesomeIcons.bagShopping,
                            count: badgeCount[0]),
                        buildTabs(context, 'Active Orders', tabIndex, index: 1,
                            onTap: () {
                          if (mounted) {
                            setState(() {
                              tabIndex = 1;
                            });
                          }
                        },
                            icon: FontAwesomeIcons.boxOpen,
                            count: badgeCount[1]),
                        buildTabs(context, 'To Rate', tabIndex, index: 2,
                            onTap: () {
                          if (mounted) {
                            setState(() {
                              tabIndex = 2;
                            });
                          }
                        },
                            icon: FontAwesomeIcons.solidStar,
                            count: badgeCount[2])
                      ]),
                ),
                SizedBox(
                    height: height - 187,
                    child: buildBasketPage(context, tabIndex))
              ],
            ),
          ),
        ));
  }

  Widget buildTabs(BuildContext context, String label, int tabIndex,
      {required VoidCallback onTap,
      required int index,
      required IconData icon,
      required int count}) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
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
                badges.Badge(
                    // badgeColor: badgeColor,
                    badgeContent: Text(
                      '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    showBadge: count > 0,
                    position: badges.BadgePosition.topEnd(top: -14, end: -12),
                    child: FaIcon(
                      icon,
                      size: 20,
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
                      fontSize: 12,
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
    return IndexedStack(
      index: tabIndex,
      children: [
        EstabBasket(
          user: widget.user,
          updateAddedProducts: (products) {
            widget.updateAddedProducts(products);
          },
          setBadgeCount: (count, index) {
            setBadgeCount(count, index);
          },
        ),
        EstabOrders(
          user: widget.user,
        ),
        Container()
      ],
    );
  }
}
