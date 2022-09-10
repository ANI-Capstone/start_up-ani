import 'package:ani_capstone/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text(
                'FEED',
                style: TextStyle(color: linkColor, fontWeight: FontWeight.bold),
              )
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.magnifyingGlass,
                  size: 20, color: linkColor),
              onPressed: () {
                //wala pay design sa search na part
              },
            )
          ],
          backgroundColor: primaryColor,
          elevation: 0),
    );
  }
}
