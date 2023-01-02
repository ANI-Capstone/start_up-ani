import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/api/notification_api.dart';
import 'package:ani_capstone/screens/components/widgets/placeholders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late final NotificationApi notificationService;

  @override
  void initState() {
    notificationService = NotificationApi();
    notificationService.initializePlatformNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Placeholders(
      type: 3,
    ));
  }
}
