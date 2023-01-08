import 'dart:async';

import 'package:ani_capstone/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Utils {
  static StreamTransformer transformer<T>(
          T Function(Map<String, dynamic> json) fromJson) =>
      StreamTransformer<QuerySnapshot, List<T>>.fromHandlers(
        handleData: (QuerySnapshot data, EventSink<List<T>> sink) {
          final snaps = data.docs.map((doc) => doc.data()).toList();

          print(snaps);

          final products = snaps
              .map((json) => fromJson(json as Map<String, dynamic>))
              .toList();
          sink.add(products);
        },
      );

  static DateTime toDateTime(Timestamp value) {
    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    return date.toUtc();
  }
}

User sampleUser = User(
    name: 'Mark Zuckmyberd',
    photoUrl: 'https://i.ibb.co/StGZh5F/20180411134321-zuck.webp',
    userId: '32');
