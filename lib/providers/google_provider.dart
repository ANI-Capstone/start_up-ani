// ignore_for_file: use_build_context_synchronously

import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/screens/home_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/auth/log_in.dart';

class GoogleProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleSignin(BuildContext context) async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (!(result == ConnectivityResult.wifi) &&
        !(result == ConnectivityResult.mobile)) {
      ShoWInfo.errorAlert(context,
          'Unable to verify, you are not connected to any network.', 5);
      return '';
    } else {
      showDialog(
          // The user CANNOT close this dialog  by pressing outsite it
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
                      borderRadius: BorderRadius.all(Radius.circular(30))),
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
                        'Validating, please wait...',
                        style: TextStyle(fontFamily: 'Roboto'),
                      )
                    ],
                  ),
                ),
              ),
            );
          });

      try {
        final googleUser = await googleSignIn.signIn();

        if (googleUser == null) return;

        _user = googleUser;

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final FirebaseAuth auth = FirebaseAuth.instance;

        // await auth.c;

        final currentUser = auth.currentUser!;

        Navigator.of(context, rootNavigator: true).pop(result);

        await FirebaseFirestoreDb.getUser(context, userId: currentUser.uid);

        notifyListeners();
        return [currentUser.email, currentUser.uid, currentUser.photoURL];
      } on FirebaseAuthException catch (e) {
        ShoWInfo.errorAlert(context, e.message.toString(), 5);
      } on Exception catch (_) {
        ShoWInfo.errorAlert(context, 'Failed due to an error occurred.', 5);
      }
    }
  }

  Future googleLogin(BuildContext context) async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (!(result == ConnectivityResult.wifi) &&
        !(result == ConnectivityResult.mobile)) {
      ShoWInfo.errorAlert(context,
          'Unable to sign up, you are not connected to any network.', 5);
      notifyListeners();

      return;
    } else {
      try {
        final googleUser = await googleSignIn.signIn();

        if (googleUser == null) return;

        _user = googleUser;

        final googleAuth = await googleUser.authentication;

        ShoWInfo.showLoadingDialog(context,
            message: "Logging in, please wait...");

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final FirebaseAuth auth = FirebaseAuth.instance;

        await auth.signInWithCredential(credential);

        Navigator.of(context, rootNavigator: true).pop(result);

        final currentUser = auth.currentUser!;

        await FirebaseFirestoreDb.getUser(context, userId: currentUser.uid);

        notifyListeners();
        return [currentUser.email, currentUser.uid, currentUser.photoURL];
      } on FirebaseAuthException catch (e) {
        Navigator.of(context, rootNavigator: true).pop(result);
        ShoWInfo.errorAlert(context, e.message.toString(), 5);
      } on Exception catch (_) {
        Navigator.of(context, rootNavigator: true).pop(result);
        ShoWInfo.errorAlert(context, 'Failed due to an error occurred.', 5);
      }
    }

    Navigator.of(context, rootNavigator: true).pop(result);
  }
}

class AccountControl {
  static Future logoutAccount(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final firebaseAuth = FirebaseAuth.instance;

    try {
      if (googleSignIn.currentUser != null) {
        await googleSignIn.signOut();
        await googleSignIn.disconnect();
      }

      await firebaseAuth.signOut().then((value) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LogIn(),
          )));
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      ShoWInfo.errorAlert(context, e.message.toString(), 5);
    }
  }

  static Future accountCheck(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ShoWInfo.showAlertDialog(context,
          title: 'Login Account',
          message: 'Account has been logout, please login again.',
          btnText: 'Login',
          onClick: () => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LogIn(),
                    ))
              });
    } else {
      return await FirebaseFirestoreDb.getUser(context,
          userId: user.uid, email: user.email);
    }
  }
}
