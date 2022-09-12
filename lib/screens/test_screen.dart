import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/api/firebase_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final id = FirebaseAuth.instance.currentUser?.uid;
    return Center(
      child: Container(
          child: StreamBuilder(
              stream:
                  FirebaseMessageApi.getChats('L5VNZfQT0adonCslrmqBQtQjZ3s2'),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data);
                  return Container();
                } else {
                  print(snapshot.data);
                  return Container();
                }
              })
          // child: ElevatedButton(
          //   onPressed: () => {
          //     // FirebaseMessageApi.getChats('L5VNZfQT0adonCslrmqBQtQjZ3s2')
          //     //     .then((value) => print(value))
          //   },
          //   child: Text('Test'),
          // ),
          ),
    );
  }
}
