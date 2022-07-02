// ignore_for_file: prefer_const_constructors

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/screens/auth/sign_up_1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:introduction_screen/introduction_screen.dart';

import 'user_control.dart';

class IntroductionPage extends StatefulWidget {
  IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserControl()),
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Container(
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/$assetName'),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final startBtn = Material(
        borderRadius: BorderRadius.circular(15),
        color: primaryColor,
        child: SizedBox(
          height: small,
          width: size.width * 0.6,
          child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {
                _onIntroEnd(context);
              },
              child: Text(
                'Let’s Get Started',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ));

    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: Container(
            color: Colors.white,
            child: IntroductionScreen(
              key: introKey,
              globalBackgroundColor: Colors.white,
              pages: [
                PageViewModel(
                    useScrollView: false,
                    image: Container(
                      height: size.height * 0.50,
                      decoration: BoxDecoration(color: primaryColor),
                      child: Stack(
                        children: [
                          Center(
                              child:
                                  Image.asset('assets/images/cute_waifu.png')),
                          Positioned(
                            bottom: 0,
                            child: Container(
                                height: size.height * 0.07,
                                width: size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40)),
                                )),
                          )
                        ],
                      ),
                    ),
                    bodyWidget: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 15),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                            style: TextStyle(
                                color: textColor.withOpacity(0.4),
                                fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 40),
                          startBtn
                        ],
                      ),
                    ),
                    titleWidget: Container(
                      width: size.width,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset('assets/images/logo.png'),
                            SizedBox(height: 20),
                            Text(
                              'Offering You the Best Goods and Services',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )
                          ]),
                    ),
                    decoration: const PageDecoration(
                      imagePadding: EdgeInsets.only(bottom: 0),
                      contentMargin: EdgeInsets.all(0),
                      titlePadding:
                          EdgeInsets.symmetric(horizontal: defaultPadding + 30),
                      bodyPadding:
                          EdgeInsets.symmetric(horizontal: defaultPadding),
                      pageColor: Colors.white,
                    )),
              ],
              onDone: () {
                _onIntroEnd(context);
              },
              showSkipButton: false,
              showBackButton: false,
              showDoneButton: false,
              showNextButton: false,
              isProgress: false,
            )));
  }
}

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
          } else if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          } else {
            return SignUp1();
          }
        },
      ),
    );
  }
}
