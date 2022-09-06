// ignore_for_file: prefer_const_constructors

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/screens/auth/log_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'user_control.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return UserControl();
          } else {
            return LogIn();
          }
        },
      ),
    );
  }
}

class OnBoardPage extends StatelessWidget {
  const OnBoardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final getStartBtn = Material(
        borderRadius: BorderRadius.circular(15),
        color: primaryColor,
        child: SizedBox(
          height: small,
          width: (size.width - (defaultPadding + 100)),
          child: MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: Text(
                'Let’s Get Started',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ));

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(color: primaryColor),
      child: Stack(
        children: [
          Positioned.fill(
              top: 20,
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'assets/images/cute_waifu.png',
                  filterQuality: FilterQuality.high,
                ),
              )),
          Positioned(
              bottom: 0,
              child: Container(
                width: size.width,
                height: size.height * 0.65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding + 10),
                  child: Column(children: [
                    SizedBox(height: 30),
                    Image.asset('assets/images/logo.png'),
                    SizedBox(height: 30),
                    Text(
                      'Offering You the Best Goods and Services',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.none),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        style: TextStyle(
                            color: textColor.withOpacity(0.5),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            decoration: TextDecoration.none),
                        textAlign: TextAlign.center),
                    SizedBox(height: 50),
                    getStartBtn,
                  ]),
                ),
              )),
        ],
      ),
    );
  }
}
