import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyProfile extends StatefulWidget {
  UserData user;
  VoidCallback toggleDrawer;
  MyProfile({Key? key, required this.user, required this.toggleDrawer})
      : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Center(
            child: Text('MY PROFILE',
                style: TextStyle(
                  color: linkColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                )),
          ),
          backgroundColor: primaryColor,
          elevation: 0),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: (defaultPadding - 20), horizontal: (defaultPadding - 10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: size.width,
                height: 70,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(widget.user.photoUrl!),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                              color: linkColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        )
                      ]),
                      SizedBox(
                          width: 24,
                          child: IconButton(
                              onPressed: () {
                                widget.toggleDrawer();
                              },
                              icon: const Icon(FontAwesomeIcons.bars,
                                  size: 20, color: linkColor))),
                    ])),
            SizedBox(height: 20),
            Text(
              'My Posts',
              style: TextStyle(
                  color: textColor.withOpacity(0.2),
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            Center(
              child: Text(
                "No posts",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      )),
    );
  }
}
