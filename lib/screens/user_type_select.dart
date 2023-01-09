// ignore_for_file: prefer_const_constructors

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/screens/user_control.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserSelect extends StatelessWidget {
  UserSelect({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final consumerBtn = Material(
        borderRadius: BorderRadius.circular(15),
        color: backgroundColor,
        child: SizedBox(
          height: small,
          child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {
                FirebaseFirestoreDb.updateUserType(context,
                        userId: user.uid,
                        userTypeId: 2,
                        userTypeName: 'Consumer')
                    .then((value) => {
                          if (value != null)
                            {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserControl(),
                                  ))
                            }
                        });
              },
              child: Text(
                'Consumer',
                textAlign: TextAlign.center,
                style: TextStyle(color: linkColor, fontWeight: FontWeight.bold),
              )),
        ));

    final farmerBtn = Material(
        borderRadius: BorderRadius.circular(15),
        color: backgroundColor,
        child: SizedBox(
          height: small,
          child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {
                FirebaseFirestoreDb.updateUserType(context,
                        userId: user.uid, userTypeId: 1, userTypeName: 'Farmer')
                    .then((value) => {
                          if (value != null)
                            {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserControl(),
                                  ))
                            }
                        });
              },
              child: Text(
                'Farmer',
                textAlign: TextAlign.center,
                style: TextStyle(color: linkColor, fontWeight: FontWeight.bold),
              )),
        ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(children: [
        Container(
          height: size.height * 0.50,
          decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40))),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'You will be using ANI as?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 40),
                    farmerBtn,
                    SizedBox(height: 20),
                    consumerBtn
                  ]),
            ),
          ),
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: defaultPadding + 20, right: defaultPadding + 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Text(
                    'Types of ANI users...',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: defaultPadding / 3),
                    child: Text(
                      'Farmer',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: textColor),
                    ),
                  ),
                  Text(
                    'A person who advertises and sells his/her produced goods.',
                    style: TextStyle(
                        fontSize: 12, color: textColor.withOpacity(0.5)),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: defaultPadding / 3),
                    child: Text(
                      'Consumer',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: textColor),
                    ),
                  ),
                  Text(
                    'A person who buys and uses up goods.',
                    style: TextStyle(
                        fontSize: 12, color: textColor.withOpacity(0.5)),
                  )
                ],
              ),
            )),
      ]),
    );
  }
}
