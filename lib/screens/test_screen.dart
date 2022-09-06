import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  UserData getData() {
    var userData = UserData(
        name: 'Marvin P. Tagolimot Jr.',
        email: 'user@gmail.com',
        phone: '090909',
        street: 'Zone 1',
        barangay: 'Sta. Ana',
        city: 'Tagoloan',
        province: 'Misamis Oriental',
        zipcode: 9001,
        photoUrl: '',
        userTypeId: 1,
        typeName: 'Farmer');

    return userData;
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestoreDb db;
    return Center(
      child: Container(
        child: ElevatedButton(
          onPressed: () => {
            FirebaseFirestoreDb.getUser(context,
                    userId: 'v7R4WRbEk1W0CzpmQRrt7Uwbgbq2')
                .then((value) => {print(value.photoUrl)})
          },
          child: Text('Test'),
        ),
      ),
    );
  }
}
