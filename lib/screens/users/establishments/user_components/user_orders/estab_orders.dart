import 'dart:async';

import 'package:ani_capstone/api/product_order_api.dart';
import 'package:ani_capstone/models/estab_order.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/screens/users/establishments/user_components/user_orders/active_orders_card.dart';
import 'package:flutter/material.dart';

class EstabOrders extends StatefulWidget {
  const EstabOrders({Key? key, required this.user}) : super(key: key);

  final UserData user;

  @override
  _EstabOrdersState createState() => _EstabOrdersState();
}

class _EstabOrdersState extends State<EstabOrders> {
  int fetchState = 0;
  StreamSubscription? listener;

  List<EstabOrder> orders = [];

  @override
  void initState() {
    fetchCreatedOrder();

    super.initState();
  }

  @override
  void dispose() {
    if (listener != null) listener!.cancel();
    super.dispose();
  }

  void fetchCreatedOrder() async {
    if (listener == null) productListener();
    ProductOrderApi.getCreatedOrders(userId: widget.user.id!).then((value) {
      if (value.isNotEmpty) {
        orders = value;
        setState(() {
          fetchState = 1;
        });
      } else {
        setState(() {
          fetchState = 2;
        });
      }
    }).onError((error, stackTrace) {
      setState(() {
        fetchState = -1;
      });
    });
  }

  void productListener() async {
    final orderRef =
        ProductOrderApi.createdOrderStream(userId: widget.user.id!);

    listener = orderRef.listen((event) async {
      fetchCreatedOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return fetchState != 1
        ? statusBuilder()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return ActiveOrdersCard(order: orders[index]);
                }),
          );
  }

  Widget statusBuilder() {
    if (fetchState == 2) {
      return SizedBox(
          height: (MediaQuery.of(context).size.height) * 0.6,
          child: const Center(child: Text('You have no active orders.')));
    } else if (fetchState == -1) {
      return SizedBox(
          height: (MediaQuery.of(context).size.height) * 0.6,
          child: const Center(
              child: Text('An error occurred, please try again.')));
    } else {
      return SizedBox(
          height: (MediaQuery.of(context).size.height) * 0.6,
          child: const Center(child: CircularProgressIndicator()));
    }
  }
}
