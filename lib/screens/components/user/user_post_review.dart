import 'dart:io';

import 'package:ani_capstone/api/firebase_filehost.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/order.dart';
import 'package:ani_capstone/models/review.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UserPostReview extends StatefulWidget {
  UserData user;
  Order order;
  UserPostReview({Key? key, required this.user, required this.order})
      : super(key: key);

  @override
  _UserPostReviewState createState() => _UserPostReviewState();
}

class _UserPostReviewState extends State<UserPostReview> {
  late User user;

  final _description = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  List<File> pickedImages = [];
  double rating = 0;

  @override
  void initState() {
    super.initState();

    user = User(
        name: widget.user.name,
        userId: widget.user.id,
        photoUrl: widget.user.photoUrl!);
  }

  void postReview() async {
    FocusScope.of(context).unfocus();
    List<String> images = [];
    List<Review> reviews = [];

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
                      'Uploading your review, please wait...',
                      style: TextStyle(fontFamily: 'Roboto'),
                    )
                  ],
                ),
              ),
            ),
          );
        });

    if (pickedImages.isNotEmpty) {
      try {
        await FirebaseStorageDb.uploadReviewImages(
                userId: user.userId!, images: pickedImages)
            .then((value) {
          images = value;
        });
      } on FirebaseException catch (_) {
        Navigator.of(context).pop();
        ShoWInfo.showToast('Failed to upload images, please try again.', 0);
        return;
      }
    }

    for (var product in widget.order.products) {
      final review = Review(
          reviewer: user,
          productId: product.productId,
          rating: rating,
          description: _description.text,
          photos: images,
          postedAt: DateTime.now());

      reviews.add(review);
    }

    ProductPost.addProductReview(
            reviews: reviews,
            productIds: widget.order.products.map((e) => e.productId).toList(),
            userId: user.userId!)
        .whenComplete(() {
      ProductPost.updateOrderStatus(
              orderStatus: 4,
              userTypeId: widget.user.userTypeId,
              order: widget.order,
              rating: rating)
          .whenComplete(() {
        Navigator.of(context).pop();
        ShoWInfo.showToast('Product review uploaded successfully.', 0);
        Navigator.of(context).pop();
      });
    }).onError((error, stackTrace) {
      Navigator.of(context).pop();
      ShoWInfo.showToast(
          'Failed to upload product review, please try again later.', 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(FontAwesomeIcons.arrowLeft,
                    color: linkColor, size: 18)),
            title: const Text('CREATE REVIEW',
                style: TextStyle(
                  color: linkColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                )),
            backgroundColor: primaryColor,
            elevation: 0),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: (25), horizontal: (25)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(user.photoUrl)),
                        const SizedBox(width: 10),
                        Text(
                          user.name,
                          style: const TextStyle(
                              color: linkColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ]),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: Center(
                            child: RatingBar.builder(
                              initialRating: 0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              unratedColor: primaryColor.withOpacity(0.7),
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemSize: 35,
                              onRatingUpdate: (rating) {
                                this.rating = rating;
                              },
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'DESCRIPTION',
                        style: TextStyle(
                            color: textColor.withOpacity(0.4),
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: descriptionField(
                            controller: _description,
                            hint: 'Tell us about you experience...',
                            lines: 6),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      _photoPreview(context),
                      const SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (rating == 0) {
                            ShoWInfo.showUpDialog(context,
                                title: 'Invalid Rating',
                                message:
                                    'Rating is required. Please add atleast 1 star.',
                                action1: 'Okay', btn1: () {
                              Navigator.of(context).pop();
                            });
                            return;
                          }

                          ShoWInfo.showUpDialog(context,
                              title: 'Post Review',
                              message:
                                  'Are you sure you want to post product review?',
                              action1: 'Yes',
                              btn1: () {
                                Navigator.of(context).pop();

                                postReview();
                              },
                              action2: 'No',
                              btn2: () {
                                Navigator.of(context).pop();
                              });
                        },
                        child: Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: primaryColor),
                            child: const Center(
                                child: Text('Post Review',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)))),
                      )
                    ]))));
  }

  Widget descriptionField(
      {String? hint,
      int lines = 1,
      required TextEditingController controller}) {
    return TextFormField(
      autofocus: false,
      maxLines: lines,
      controller: controller,
      keyboardType: TextInputType.text,
      onSaved: (value) {
        controller.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(color: primaryColor),
        contentPadding: const EdgeInsets.fromLTRB(15, 12, 20, 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          const Text(
            "Add photos to your post",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.camera, color: linkColor),
              onPressed: () {
                Navigator.pop(context);
                pickImages(ImageSource.camera);
              },
              label: const Text("Camera", style: TextStyle(color: textColor)),
            ),
            const SizedBox(
              width: 20,
            ),
            TextButton.icon(
              icon: const Icon(Icons.image, color: linkColor),
              onPressed: () {
                Navigator.pop(context);
                pickImages(ImageSource.gallery);
              },
              label: const Text("Gallery", style: TextStyle(color: textColor)),
            ),
          ])
        ],
      ),
    );
  }

  Widget _photoPreview(BuildContext context) {
    return pickedImages.isEmpty ? _emptyPhoto(context) : _postImages(context);
  }

  Widget _postImages(BuildContext context) {
    if (pickedImages.length == 1) {
      return Container(
        height: 120,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showImage(context, 0),
            const SizedBox(width: 30),
            addMorePhotos(context)
          ],
        ),
      );
    } else if (pickedImages.length >= 2) {
      return Container(
        height: 120,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showImage(context, 0),
            const SizedBox(width: 15),
            showImage(context, 1, isMany: true),
            const SizedBox(width: 15),
            addMorePhotos(context)
          ],
        ),
      );
    }

    return _emptyPhoto(context);
  }

  Widget showImage(BuildContext context, int index, {bool isMany = false}) {
    return isMany
        ? Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: pickedImages.length < 3
                      ? Image.file(
                          pickedImages[index],
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.file(
                              pickedImages[index],
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                  color: plusColor.withOpacity(0.75),
                                  shape: BoxShape.circle),
                              child: Center(
                                  child: Text('+${pickedImages.length - 2}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: linkColor,
                                          fontWeight: FontWeight.bold))),
                            )
                          ],
                        )),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      pickedImages.removeAt(index);
                    });
                  },
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.xmark,
                        color: linkColor,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        : Stack(children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.file(
                  pickedImages[index],
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                )),
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    pickedImages.removeAt(index);
                  });
                },
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.xmark,
                      color: linkColor,
                      size: 12,
                    ),
                  ),
                ),
              ),
            )
          ]);
  }

  Widget addMorePhotos(BuildContext context) {
    return Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(5)),
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: ((builder) => bottomSheet()),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                  height: 32, width: 32, 'assets/icons/add_more_image.png'),
              const Text(
                'Add Photos',
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ));
  }

  Widget _emptyPhoto(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(color: primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(5)),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: ((builder) => bottomSheet()),
          );
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/add_image.png',
                width: 48,
                height: 48,
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Add Photos',
                style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.bold),
              )
            ]),
      ),
    );
  }

  Future pickImages(ImageSource source) async {
    try {
      if (source.name == 'gallery') {
        final List<XFile>? images = await _picker.pickMultiImage();

        if (images != null) {
          setState(() {
            pickedImages.addAll(images.map((img) => File(img.path)).toList());
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(source: source);
        setState(() {
          pickedImages.add(File(image!.path));
        });
      }
    } on Exception catch (e) {
      ShoWInfo.errorAlert(context, e.toString(), 5);
    }
    if (pickedImages.isEmpty) return;
  }
}
