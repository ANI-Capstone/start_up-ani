// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

    var imageUrl = null;

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
}
