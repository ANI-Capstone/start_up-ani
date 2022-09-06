// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../constants.dart';

class FacebookProvider {
  static Future signUpFacebook(BuildContext context) async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (!(result == ConnectivityResult.wifi) &&
        !(result == ConnectivityResult.mobile)) {
      ShoWInfo.errorAlert(context,
          'Unable to sign up, you are not connected to any network.', 5);
      return;
    } else {
      try {
        final facebookLoginResult = await FacebookAuth.instance.login(
            permissions: [
              'email',
              'public_profile',
              'user_hometown',
              'user_location'
            ]);
        final userData = await FacebookAuth.instance.getUserData();

        final facebookAuthCredential = FacebookAuthProvider.credential(
            facebookLoginResult.accessToken!.token);

        final FirebaseAuth auth = FirebaseAuth.instance;

        await auth.signInWithCredential(facebookAuthCredential);

        return [userData, auth.currentUser?.uid];
      } on FirebaseAuthException catch (e) {
        ShoWInfo.errorAlert(context, e.message.toString(), 5);
        return;
      } on Exception catch (e) {
        ShoWInfo.errorAlert(
            context, 'Unable to proceed, due to an error occurred.', 5);
        return;
      }

      // await FirebaseFirestore.instance.collection('users').add({
      //   'email': userData['email'],
      //   'imageUrl': userData['picture']['data']['url'],
      //   'name': userData['name']
      // });
    }
  }
}
