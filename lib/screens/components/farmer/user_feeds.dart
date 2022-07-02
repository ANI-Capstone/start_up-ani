import 'package:ani_capstone/constants.dart';
import 'package:flutter/material.dart';

class UserFeeds extends StatefulWidget {
  UserFeeds({Key? key}) : super(key: key);

  @override
  State<UserFeeds> createState() => _UserFeedsState();
}

class _UserFeedsState extends State<UserFeeds> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: [
              Text(
                'FEED',
                style: TextStyle(color: linkColor, fontWeight: FontWeight.bold),
              )
            ],
          ),
          backgroundColor: primaryColor,
          elevation: 0),
    );
  }
}
