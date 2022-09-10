import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants.dart';

class UserPost extends StatefulWidget {
  UserPost({Key? key}) : super(key: key);

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Row(
              children: [
                Text('CREATE POST',
                    style: TextStyle(
                        color: linkColor, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.circleXmark,
                  size: 20, color: linkColor),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
          backgroundColor: primaryColor,
          elevation: 0),
    );
  }
}
