// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/auth/log_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../constants.dart';
import '../../../api/firebase_firestore.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final user = FirebaseAuth.instance.currentUser!;
  UserData? userData;

  Future getUserData() async {
    return mounted
        ? FirebaseFirestoreDb.getUser(context, userId: user.uid)
            .then((value) => {userData = value})
        : userData;
  }

  Widget _profileDashboard(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final logOutButton = SizedBox(
        height: small,
        child: Material(
          borderRadius: BorderRadius.circular(15),
          color: primaryColor,
          child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) {
                      return Dialog(
                        // The background color
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Container(
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                // The loading indicator
                                CircularProgressIndicator(
                                  color: primaryColor,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                // Some text
                                Text(
                                  'Logging out, please wait...',
                                  style: TextStyle(fontFamily: 'Roboto'),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });

                AccountControl.logoutAccount(context);
              },
              child: Text(
                "Log Out",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ));

    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
          leading: const BackButton(
            color: linkColor,
          ),
          centerTitle: true,
          title: Text('MY PROFILE',
              style: TextStyle(
                color: linkColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              )),
          backgroundColor: primaryColor,
          elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: FutureBuilder(
            future: getUserData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return ShoWInfo.errorAlert(
                    context, snapshot.error.toString(), 5);
              } else {
                return Column(children: [
                  SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                InkWell(
                                  child: CircleAvatar(
                                    backgroundColor: linkColor,
                                    radius: 70,
                                    child: CircleAvatar(
                                      radius: 68,
                                      backgroundColor: Colors.white,
                                      backgroundImage: userData?.photoUrl !=
                                              null
                                          ? NetworkImage(
                                              userData?.photoUrl as String)
                                          : AssetImage('assets/images/user.png')
                                              as ImageProvider,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  userData?.name as String,
                                  style: const TextStyle(
                                      color: linkColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 40),
                          CustomButton.customIconButton(context,
                              size: size,
                              height: small,
                              icon: FontAwesomeIcons.solidUser,
                              label: 'Name',
                              text: userData?.name),
                          SizedBox(height: 10),
                          CustomButton.customIconButton(context,
                              size: size,
                              height: small,
                              icon: FontAwesomeIcons.solidEnvelope,
                              label: 'Email',
                              text: userData?.email),
                          SizedBox(height: 10),
                          CustomButton.customIconButton(context,
                              size: size,
                              height: small,
                              icon: FontAwesomeIcons.lock,
                              label: 'Password',
                              text: "*************"),
                          SizedBox(height: 10),
                          CustomButton.customIconButton(context,
                              size: size,
                              height: small,
                              icon: FontAwesomeIcons.phone,
                              label: 'Phone',
                              text: userData?.phone),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'ADDRESS',
                              style: TextStyle(
                                  color: textColor.withOpacity(0.4),
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ]),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                      width: size.width,
                      height: medium,
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: backgroundColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  FontAwesomeIcons.locationDot,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Flexible(
                                  child: SizedBox(
                                    width: (size.width - 30),
                                    child: Text(
                                        ('${userData?.street}, ${userData?.barangay}, ${userData?.city}, ${userData?.province}, ${userData?.zipcode}'
                                                    .length <
                                                60)
                                            ? '${userData?.street}, ${userData?.barangay}, ${userData?.city}, ${userData?.province}, ${userData?.zipcode}'
                                            : '${'${userData?.street}, ${userData?.barangay}, ${userData?.city}, ${userData?.province}, ${userData?.zipcode}'.characters.take(57)}...',
                                        style: TextStyle(
                                          color: linkColor.withOpacity(0.8),
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ))),
                  SizedBox(height: 30),
                  logOutButton
                ]);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
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
              child: FutureBuilder(
                future: getUserData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return ShoWInfo.errorAlert(
                        context, snapshot.error.toString(), 5);
                  } else {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              backgroundImage: userData?.photoUrl != null
                                  ? NetworkImage(userData?.photoUrl as String)
                                  : const AssetImage('assets/images/user.png')
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              userData?.name != null
                                  ? userData?.name as String
                                  : 'No user data',
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              _profileDashboard(context),
                                        ));
                                  },
                                  icon: const Icon(FontAwesomeIcons.bars,
                                      size: 24, color: linkColor))),
                        ]);
                  }
                },
              ),
            ),
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
                "No post available",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      )),
    );
  }
}
