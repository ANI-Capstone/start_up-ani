// ignore_for_file: use_build_context_synchronously

import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/screens/home_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/streams.dart';

import '../screens/auth/log_in.dart';

class GoogleProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  FirebaseAuth auth = FirebaseAuth.instance;

  Future googleSignin(BuildContext context) async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (!(result == ConnectivityResult.wifi) &&
        !(result == ConnectivityResult.mobile)) {
      ShoWInfo.errorAlert(context,
          'Unable to verify, you are not connected to any network.', 5);
      return '';
    } else {
      try {
        if (googleSignIn.currentUser != null) {
          await googleSignIn.disconnect();
        }
        final googleUser = await googleSignIn.signIn();

        if (googleUser == null) return null;

        _user = googleUser;

        final googleAuth = await googleUser.authentication;

        ShoWInfo.showLoadingDialog(context,
            message: "Validating, please wait...");

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final FirebaseAuth auth = FirebaseAuth.instance;

        await auth.signInWithCredential(credential);

        Navigator.of(context, rootNavigator: true).pop(result);

        final currentUser = auth.currentUser!;

        var exist =
            await FirebaseFirestoreDb.checkExistUser(userId: currentUser.uid);

        if (exist) {
          ShoWInfo.errorAlert(context,
              'This email address is already in use by another account.', 5);
          return null;
        }
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
        if (googleSignIn.currentUser != null) {
          await googleSignIn.disconnect();
        }

        final googleUser = await googleSignIn.signIn();

        if (googleUser == null) return null;

        _user = googleUser;

        final googleAuth = await googleUser.authentication;

        ShoWInfo.showLoadingDialog(context,
            message: "Logging in, please wait...");

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await auth.signInWithCredential(credential).then((value) =>
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage())));

        Navigator.of(context, rootNavigator: true).pop(result);

        notifyListeners();
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

class AccountControl extends ChangeNotifier {
  static GoogleSignIn googleSignIn = GoogleSignIn();
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  static getUserId() {
    final firebaseAuth = FirebaseAuth.instance;

    return firebaseAuth.currentUser?.uid;
  }

  static logoutAccount(BuildContext context) async {
    try {
      if (googleSignIn.currentUser != null) {
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }

      await firebaseAuth.signOut().whenComplete(() {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogIn(),
            ));
      });
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      ShoWInfo.errorAlert(context, e.message.toString(), 5);
    }
  }

  static bool isUserLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    } else {
      return true;
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
