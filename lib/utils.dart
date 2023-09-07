import 'dart:async';

import 'package:ani_capstone/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'models/post.dart';

class Utils {
  static NumberFormat numberFormat = NumberFormat.decimalPattern('en_us');
  static const String cn = '\u20B1';

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

  static double productRating(double rate, int rateCount, double rating) {
    final sum = (rating * rateCount) + rate;

    return sum / (rateCount + 1);
  }

  static double computeRating(List<Post> posts) {
    final ratings = [];

    for (var post in posts) {
      if (post.rateCount! > 0) {
        ratings.add(post.rating);
      }
    }

    if (ratings.isEmpty) {
      return 0;
    }

    final sum = ratings.reduce((a, b) => a + b);

    return sum / ratings.length;
  }

  static String getFormattedDateSimple(int time) {
    DateFormat newFormat = DateFormat("MM/dd/yyyy - EEEE");
    return newFormat.format(DateTime.fromMillisecondsSinceEpoch(time));
  }

  static String specifiedDateTime(DateTime datetime) {
    return DateFormat('MM/dd/yyyy, hh:mm a').format(datetime);
  }
}

User sampleUser = User(
    name: 'Mark Zuckmyberd',
    photoUrl: 'https://i.ibb.co/StGZh5F/20180411134321-zuck.webp',
    userId: '32');

class Policy {
  static const double minimumOrder = 0;
}
