import 'package:flutter/material.dart';

import '../../../constants.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
            child: Row(
              children: [Text('PROFILE')],
            ),
          ),
          backgroundColor: primaryColor,
          elevation: 0),
    );
  }
}
