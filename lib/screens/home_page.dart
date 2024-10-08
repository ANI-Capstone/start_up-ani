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
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/ani_logo.png',
                            width: 200,
                            height: 200,
                            filterQuality: FilterQuality.high),
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
                            "A system which creates a direct connection between farmers and consumers, eradicating the existence of intermediary entities. This application is intended for farmers who are about to sell their produced goods and for consumers who are about to buy a farmer's produced goods, creating a vital link between both target users.",
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
