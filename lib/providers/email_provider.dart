// ignore_for_file: use_build_context_synchronously

import 'package:ani_capstone/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class EmailProvider {
  static Future createAccountEmail(BuildContext context,
      {required String email, required String password}) async {
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
        final FirebaseAuth auth = FirebaseAuth.instance;

        await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );

        Navigator.of(context).pop();

        return auth.currentUser?.uid;
      } on FirebaseAuthException catch (e) {
        Navigator.of(context).pop();

        ShoWInfo.errorAlert(context, e.message.toString(), 5);
        return '';
      }
    }
  }

  static Future loginAccountEmail(BuildContext context,
      {required String email, required String password}) async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (!(result == ConnectivityResult.wifi) &&
        !(result == ConnectivityResult.mobile)) {
      ShoWInfo.errorAlert(
          context, 'Unable to login, you are not connected to any network.', 5);
      return null;
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
                        'Logging in, please wait...',
                        style: TextStyle(fontFamily: 'Roboto'),
                      )
                    ],
                  ),
                ),
              ),
            );
          });

      try {
        final FirebaseAuth auth = FirebaseAuth.instance;

        await auth
            .signInWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            )
            .then((value) =>
                Navigator.of(context, rootNavigator: true).pop(result));

        return auth.currentUser?.uid;
      } on FirebaseAuthException catch (e) {
        Navigator.of(context, rootNavigator: true).pop(result);

        ShoWInfo.errorAlert(context, e.message.toString(), 5);
        return null;
      }
    }
  }
}
