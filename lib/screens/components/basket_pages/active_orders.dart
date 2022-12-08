import 'dart:async';

import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/models/order.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/basket_pages/orders_card.dart';
import 'package:flutter/material.dart';
import 'package:ani_capstone/models/user_data.dart';

class ActiveOrders extends StatefulWidget {
  UserData user;
  int orderStatus;
  List<Order> order;
  int fetchState;
  ActiveOrders(
      {Key? key,
      required this.user,
      required this.orderStatus,
      required this.order,
      required this.fetchState})
      : super(key: key);

  @override
  _ActiveOrdersState createState() => _ActiveOrdersState();
}

class _ActiveOrdersState extends State<ActiveOrders> {
  late User user;

  @override
  void initState() {
    super.initState();

    user = User(
        name: widget.user.name,
        userId: widget.user.id,
        photoUrl: widget.user.photoUrl!);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return widget.fetchState != 1
        ? statusBuilder()
        : SizedBox(
            height: height - 230,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.order.length,
                  itemBuilder: (context, index) {
                    return buildProduct(widget.order[index]);
                  }),
            ),
          );
  }

  Widget statusBuilder() {
    if (widget.fetchState == 2) {
      return const Center(child: Text('Order is empty.'));
    } else if (widget.fetchState == -1) {
      return const Center(child: Text('An error occured, please try again.'));
    } else {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }

  Widget buildProduct(Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: OrdersCard(
        order: order,
        user: widget.user,
      ),
    );
  }
}
