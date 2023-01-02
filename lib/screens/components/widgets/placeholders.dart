import 'package:ani_capstone/constants.dart';
import 'package:flutter/material.dart';

class Placeholders extends StatelessWidget {
  final int type;
  const Placeholders({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (type == 1) {
      return noPost();
    } else if (type == 2) {
      return noChats();
    } else if (type == 3) {
      return noOrders();
    } else if (type == 4) {
      return noProductreview();
    } else {
      return noNotifications();
    }
  }

  Widget noPost() {
    return Container(
      color: userBgColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_post.png',
            height: 155,
            width: 170,
          ),
          Text('No post available',
              style: TextStyle(
                  fontFamily: 'assets/font/Roboto-Regular.ttf',
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ],
      ),
    );
  }

  Widget noChats() {
    return Container(
      color: userBgColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_chats.png',
            height: 155,
            width: 170,
          ),
          Text('No chats available',
              style: TextStyle(
                  fontFamily: 'assets/font/Roboto-Regular.ttf',
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ],
      ),
    );
  }

  Widget noOrders() {
    return Container(
      color: userBgColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_orders.png',
            height: 155,
            width: 170,
          ),
          Text('No orders available',
              style: TextStyle(
                  fontFamily: 'assets/font/Roboto-Regular.ttf',
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ],
      ),
    );
  }

  Widget noProductreview() {
    return Container(
      color: userBgColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/no_review.png', height: 155, width: 170),
          Text('You have no product review yet',
              style: TextStyle(
                  fontFamily: 'assets/font/Roboto-Regular.ttf',
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ],
      ),
    );
  }

  Widget noNotifications() {
    return Container(
      color: userBgColor,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_notifications.png',
            height: 155,
            width: 170,
          ),
          Text('No notifications',
              style: TextStyle(
                  fontFamily: 'assets/font/Roboto-Regular.ttf',
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
        ],
      ),
    );
  }
}
