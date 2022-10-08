// ignore_for_file: use_build_context_synchronously

import 'package:ani_capstone/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ProductPost {
  static Future uploadPost(BuildContext context, {required Post post}) async {
    final posts = FirebaseFirestore.instance.collection('posts');

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
                      'Uploading your post, please wait...',
                      style: TextStyle(fontFamily: 'Roboto'),
                    )
                  ],
                ),
              ),
            ),
          );
        });

    try {
      await posts.add(post.toJson());

      Navigator.of(context).pop();
      ShoWInfo.successAlert(
          context, 'Your post has been posted successfully.', 5);

      return true;
    } on Exception catch (e) {
      Navigator.of(context).pop();
      ShoWInfo.errorAlert(
          context, 'Failed to upload your post, please try again later.', 5);
      return false;
    }
  }
}
