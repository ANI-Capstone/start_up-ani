import 'package:flutter/material.dart';

import '../../../constants.dart';

class UserInbox extends StatefulWidget {
  UserInbox({Key? key}) : super(key: key);

  @override
  State<UserInbox> createState() => _UserInboxState();
}

class _UserInboxState extends State<UserInbox> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
            children: [Text('INBOX')],
          ),
          backgroundColor: primaryColor,
          elevation: 0),
    );
  }
}
