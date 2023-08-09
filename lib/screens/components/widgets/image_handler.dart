import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../constants.dart';

class ImageHandler extends StatelessWidget {
  final int imageType;
  final String image;

  const ImageHandler({Key? key, required this.image, this.imageType = 0})
      : super(key: key);

  static const int userProfile = 1;
  static const int postImage = 2;
  static const int productImage = 3;

  @override
  Widget build(BuildContext context) {
    if (imageType == userProfile) {
      return buildProfileImage();
    } else if (imageType == postImage) {
      return buildPostImage();
    }

    return CachedNetworkImage(
      imageUrl: image,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) =>
          const Icon(Icons.error, size: 12, color: linkColor),
    );
  }

  Widget buildProfileImage() {
    return CircleAvatar(
        backgroundColor: primaryColor,
        radius: 22,
        backgroundImage: CachedNetworkImageProvider(
          image,
          errorListener: () =>
              const Icon(Icons.error, size: 12, color: linkColor),
        ));
  }

  Widget buildPostImage() {
    return CachedNetworkImage(
      imageUrl: image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 150,
      errorWidget: (context, url, error) =>
          const Icon(Icons.error, size: 12, color: linkColor),
    );
  }
}
