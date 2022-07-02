import 'package:flutter/material.dart';

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
          title: Center(
            child: Row(
              children: [Text('CREATE POST')],
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0),
    );
  }
}
