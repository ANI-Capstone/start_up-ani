import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class FirebaseMessageApi {
  static Stream<List<User>> getUsers() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());
}
