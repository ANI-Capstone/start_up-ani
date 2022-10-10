import 'package:ani_capstone/constants.dart';
import 'package:flutter/material.dart';

class UserReviews extends StatelessWidget {
  const UserReviews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(
            child: Row(
              children: const [
                Text('RATINGS',
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
