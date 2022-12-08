// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../constants.dart';

class FirebaseStorageDb {
  static Future uploadImage(BuildContext context,
      {required String userId,
      required String path,
      required File? imageFile}) async {
    final ref =
        FirebaseStorage.instance.ref().child('$userId/$path/$userId-image-url');

    UploadTask uploadTask = ref.putFile(imageFile!);

    final ConnectivityResult result = await Connectivity().checkConnectivity();

    var imageUrl;

    if (!(result == ConnectivityResult.wifi) &&
        !(result == ConnectivityResult.mobile)) {
      ShoWInfo.errorAlert(context,
          'Unable to upload, you are not connected to any network.', 5);

      return;
    } else {
      ShoWInfo.processAlert(context, 'Uploading your photo...', 5);

      try {
        await uploadTask.whenComplete(() => {
              imageUrl = ref.getDownloadURL(),
              ShoWInfo.successAlert(
                  context, 'Your photo has been changed successfully.', 5)
            });
      } on FirebaseException catch (e) {
        ShoWInfo.errorAlert(context, e.message.toString(), 5);
      }

      return imageUrl;
    }
  }

  static Future changeProfilePic(
      {required String userId, required File? imageFile}) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('$userId/image-url/$userId-image-url');

    UploadTask uploadTask = ref.putFile(imageFile!);

    var imageUrl;

    await uploadTask.whenComplete(() {
      imageUrl = ref.getDownloadURL();
    });

    return imageUrl;
  }

  static Future<List<String>> uploadPostImages(
      {required String userId, required List<File> images}) async {
    var imageUrls =
        await Future.wait(images.map((img) => _uploadPostImage(img, userId)));
    return imageUrls;
  }

  static Future<String> _uploadPostImage(File img, String userId) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('$userId/posts/${basename(img.path)}');

    UploadTask uploadTask = ref.putFile(img);
    await uploadTask;

    return await ref.getDownloadURL();
  }

  static Future<String> uploadMessageImage(File img, String userId) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('$userId/image-messages/${basename(img.path)}');

    UploadTask uploadTask = ref.putFile(img);

    bool doneUpload = false;

    await uploadTask.whenComplete(() {
      doneUpload = true;
    });

    if (doneUpload) {
      return await ref.getDownloadURL();
    }

    return 'failed';
  }
}
