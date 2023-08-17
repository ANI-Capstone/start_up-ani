import 'package:ani_capstone/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountApi {
  static Future updateUserData(
      {required String userId, required UserData userData}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    final data = userData.toJson();

    return await userRef.update(data);
  }

  static Future updateEmail(
      {required String userId, required String newEmail}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    return await userRef.update({'email': newEmail});
  }

  static Future setFcmToken(
      {required String userId, required String fcmToken}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    return await userRef.update({'fcmToken': fcmToken});
  }

  static Future<UserData> getUserData(String userId) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((value) => UserData.fromJson(value.data()!));
}
