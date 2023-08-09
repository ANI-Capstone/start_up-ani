import 'dart:io';

// import 'package:ani_capstone/api/firebase_filehost.dart';
// import 'package:ani_capstone/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';

import '../../../constants.dart';

class ImagePreview extends StatelessWidget {
  String image;
  ImagePreview({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(FontAwesomeIcons.arrowLeft,
                    color: Colors.white, size: 18)),
            title: const Text('Preview Image',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                  fontSize: 16,
                )),
            backgroundColor: Colors.black,
            elevation: 0),
        backgroundColor: Colors.black,
        body: SizedBox(
          height: MediaQuery.of(context).size.height - 120,
          child: PhotoView(
            imageProvider: image.contains('https://')
                ? 
                CachedNetworkImageProvider(
  image,
  errorListener: () => const Icon(
                                Icons.error,
                                size: 12,
                                color: linkColor),
)
              
                : Image.file(File(image), fit: BoxFit.cover).image,
          ),
        ));
  }
}
