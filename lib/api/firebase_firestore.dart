// ignore_for_file: use_build_context_synchronously
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/screens/auth/sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class FirebaseFirestoreDb {
  static Future addAccount(BuildContext context, UserData userData) async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (!(result == ConnectivityResult.wifi) &&
        !(result == ConnectivityResult.mobile)) {
      ShoWInfo.errorAlert(context,
          'Unable to create account, you are not connected to any network.', 5);
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return Dialog(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(
                        color: primaryColor,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Creating account, please wait...',
                        style: TextStyle(fontFamily: 'Roboto'),
                      )
                    ],
                  ),
                ),
              ),
            );
          });

      try {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(userData.id);

        userRef.set({
          'id': userData.id,
          'email': userData.email,
          'imageUrl': userData.photoUrl,
          'name': userData.name,
          'phone': userData.phone,
          'address': {
            'street': userData.street,
            'barangay': userData.barangay,
            'city': userData.city,
            'province': userData.province,
            'zipcode': userData.zipcode
          },
          'userType': {'userTypeId': null, 'typeName': null}
        });

        Navigator.of(context).pop();

        return 'Success';
      } on FirebaseException catch (e) {
        ShoWInfo.errorAlert(context, e.message.toString(), 5);
        Navigator.of(context).pop();
      }
    }

    return 'Failed';
  }

  static Future<bool> checkExistUser({required String userId}) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((value) => value.exists);
  }

  static Future getUser(BuildContext context,
      {required String userId, String? email}) async {
    var userData;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((value) => {userData = value});

    return fromJson(userData, context, userId, email: email);
  }

  static Future updateUserType(BuildContext context,
      {required userId, required userTypeId, required userTypeName}) async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (!(result == ConnectivityResult.wifi) &&
        !(result == ConnectivityResult.mobile)) {
      ShoWInfo.errorAlert(context, 'You are not connected to any network.', 5);
      return null;
    } else {
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
                        'Loading, please wait...',
                        style: TextStyle(fontFamily: 'Roboto'),
                      )
                    ],
                  ),
                ),
              ),
            );
          });

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'userType': {'userTypeId': userTypeId, 'typeName': userTypeName}
        });
        Navigator.of(context).pop();
        return 'Success';
      } on FirebaseException catch (e) {
        ShoWInfo.errorAlert(context, e.message.toString(), 5);
        Navigator.of(context).pop();
        return null;
      }
    }
  }

  static fromJson(DocumentSnapshot<Map<String, dynamic>> json,
      BuildContext context, String userId,
      {String? email}) {
    if (json.data() == null) {
      return ShoWInfo.showAlertDialog(context,
          title: 'Account Registration',
          message: "Please complete your account registration.",
          btnText: 'Continue', onClick: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SignUp(userId: userId, userEmail: email, index: 1),
            ));
      });
    }

    var userData = UserData(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        street: json['address']['street'],
        barangay: json['address']['barangay'],
        city: json['address']['city'],
        province: json['address']['province'],
        zipcode: json['address']['zipcode'],
        photoUrl: json['imageUrl'],
        typeName: json['userType']['typeName'] ?? "null",
        userTypeId: json['userType']['userTypeId'] ?? 0);

    return userData;
  }
}
