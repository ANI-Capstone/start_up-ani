import 'package:flutter/material.dart';

import '../../../constants.dart';

class UserNotificaiton extends StatefulWidget {
  UserNotificaiton({Key? key}) : super(key: key);

  @override
  State<UserNotificaiton> createState() => _UserNotificaitonState();
}

class _UserNotificaitonState extends State<UserNotificaiton> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Row(
              children: [
                Text('NOTIFICATIONS',
                    style: TextStyle(
                        color: linkColor, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0),
    );
  }
}
