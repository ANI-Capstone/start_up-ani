import 'dart:io';

import 'package:ani_capstone/api/firebase_filehost.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_place/google_place.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ani_capstone/models/user_data.dart';
import '../../../constants.dart';
import '../../../models/post.dart';
import '../../../models/user.dart';

class EditPost extends StatefulWidget {
  Post post;
  VoidCallback? fetchData;
  EditPost({Key? key, required this.post, this.fetchData}) : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  late Post post;
  late GooglePlace googlePlace;

  final _formKey = GlobalKey<FormState>();
  final _productName = TextEditingController();
  final _productDescription = TextEditingController();
  final _productPrice = TextEditingController();
  final _newLocation = TextEditingController();

  String? productUnit;
  String? location;

  final ImagePicker _picker = ImagePicker();
  List<AutocompletePrediction> predictions = [];
  List<File> pickedImages = [];

  bool confirmPost = false;

  @override
  void initState() {
    super.initState();

    post = widget.post;
    productUnit = post.unit;
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);

    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  bool checkChanges() {
    return _productName.text.isNotEmpty ||
        _productDescription.text.isNotEmpty ||
        _productPrice.text.isNotEmpty ||
        pickedImages.isNotEmpty ||
        productUnit != post.unit;
  }

  void updatePost() async {
    List<String> images = [];

    if (pickedImages.isNotEmpty) {
      try {
        ShoWInfo.showToast('Please wait, uploading images.', 3);
        await FirebaseStorageDb.uploadPostImages(
                userId: widget.post.publisher.userId!, images: pickedImages)
            .then((value) => {
                  ShoWInfo.showToast('Uploaded successfully.', 3),
                  images = value
                });
      } on FirebaseException catch (_) {
        ShoWInfo.showToast('Upload failed, unable to upload images.', 3);
        return null;
      } on Exception catch (_) {
        ShoWInfo.showToast('Upload failed, unable to upload images.', 3);
        return null;
      }
    }

    final updatedPost = Post(
      postId: post.postId,
      description: _productDescription.text.isNotEmpty
          ? _productDescription.text.trim()
          : post.description,
      publisher: post.publisher,
      name: _productName.text.isNotEmpty ? _productName.text.trim() : post.name,
      price: _productPrice.text != '${post.price}'
          ? double.parse(_productPrice.text.trim())
          : post.price,
      unit: productUnit != post.unit ? productUnit! : post.unit,
      location: post.location,
      images: images.isNotEmpty ? images : post.images,
      postedAt: post.postedAt,
      likes: post.likes,
      reviews: post.reviews,
    );

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
                      'Updating post, please wait...',
                      style: TextStyle(fontFamily: 'Roboto'),
                    )
                  ],
                ),
              ),
            ),
          );
        });

    ProductPost.updatePost(post: updatedPost)
        .whenComplete(() => {
              ShoWInfo.showToast('Post updated successfully.', 3),
              Navigator.of(context).pop(),
              widget.fetchData!(),
              Navigator.of(context).pop(),
            })
        .onError((error, stackTrace) => {
              Navigator.of(context).pop(),
              ShoWInfo.showToast('Failed, an error occured.', 3)
            });
  }

  @override
  Widget build(BuildContext context) {
    var items1 = ['Kilogram', 'Gram', 'Pound'];
    var items2 = ['Default Address', 'Locate New Address'];

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(FontAwesomeIcons.arrowLeft,
                    color: linkColor, size: 18)),
            title: const Text('EDIT POST',
                style: TextStyle(
                  color: linkColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                )),
            centerTitle: true,
            backgroundColor: primaryColor,
            elevation: 0),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: (defaultPadding - 5),
                horizontal: (defaultPadding - 5)),
            child: Column(
              children: [
                Row(children: [
                  CircleAvatar(
                      radius: 22,
                      backgroundColor: primaryColor,
                      backgroundImage:
                          CachedNetworkImageProvider(post.publisher.photoUrl)),
                  const SizedBox(width: 10),
                  Text(
                    post.publisher.name,
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const Expanded(child: SizedBox(width: 1)),
                  TextButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();

                      if (!checkChanges()) {
                        ShoWInfo.showUpDialog(context,
                            title: 'Update Post',
                            message:
                                "Fields are empty, no changes will be made to your post.",
                            action1: 'Okay', btn1: () {
                          Navigator.of(context).pop();
                        });
                      } else {
                        ShoWInfo.showUpDialog(context,
                            title: 'Update Profile',
                            message:
                                "Are you sure you want to update your post?",
                            action1: 'Save Changes',
                            btn1: () {
                              Navigator.of(context).pop();
                              updatePost();
                            },
                            action2: 'Cancel',
                            btn2: () {
                              Navigator.of(context).pop();
                            });
                      }
                    },
                    child: const Text('UPDATE',
                        style: TextStyle(
                            color: linkColor, fontWeight: FontWeight.bold)),
                  ),
                ]),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      _cTextField(
                          controller: _productName,
                          hint: post.name,
                          validator: 'Product name'),
                      const SizedBox(
                        height: 20,
                      ),
                      _cTextField(
                          controller: _productDescription,
                          hint: post.description,
                          lines: 5,
                          validator: 'Product details'),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                                controller: _productPrice,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                    isDense: true,
                                    enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: primaryColor, width: 1.5)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 5),
                                    hintText: '${post.price}',
                                    hintStyle:
                                        const TextStyle(color: primaryColor),
                                    prefixIconConstraints: const BoxConstraints(
                                        minWidth: 23, maxHeight: 20),
                                    suffixIconConstraints: const BoxConstraints(
                                        minWidth: 23, maxHeight: 20),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.zero,
                                      child: FaIcon(FontAwesomeIcons.pesoSign,
                                          color: primaryColor, size: 16),
                                    ),
                                    suffixIcon: const Padding(
                                      padding: EdgeInsets.zero,
                                      child: Text(
                                        '.00',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return ("Price is required");
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _productPrice.text = value!;
                                }),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          Expanded(
                            child: DropdownButton(
                              value: productUnit,
                              items: items1.asMap().entries.map((item) {
                                return DropdownMenuItem(
                                    value: item.value,
                                    child: Text(
                                      item.value,
                                      style: const TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ));
                              }).toList(),
                              hint: const Text('UNIT',
                                  style: TextStyle(
                                    color: primaryColor,
                                  )),
                              underline: Container(
                                height: 1.5,
                                color: primaryColor,
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: primaryColor,
                              ),
                              isExpanded: true,
                              onChanged: (String? newValue) {
                                setState(() {
                                  productUnit = newValue!;
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      _locationDropdown(hint: 'LOCATION', items: items2),
                      const SizedBox(
                        height: 30,
                      ),
                      _photoPreview(context)
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _locationDropdown({
    required String hint,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: primaryColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            hint: Text(hint,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            value: 'Default Address',
            isExpanded: true,
            elevation: 0,
            dropdownColor: primaryColor,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            items: items.asMap().entries.map((item) {
              return DropdownMenuItem(
                value: item.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.value,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    FaIcon(
                      item.key == 0
                          ? FontAwesomeIcons.locationDot
                          : FontAwesomeIcons.magnifyingGlass,
                      size: 18,
                      color: Colors.white,
                    )
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                location = newValue!;
              });

              if (newValue == 'Locate New Address') {
                // showDialog(
                //   context: context,
                //   builder: (BuildContext context) {
                //     return _cInputDialog(context);
                //   },
                // );
              } else {
                _newLocation.text = post.location;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _cInputDialog(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Locate New Address',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _newLocation,
        decoration: InputDecoration(
          hintText: 'Search address',
          hintStyle:
              const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          contentPadding: const EdgeInsets.fromLTRB(5, 12, 0, 12),
          suffixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: IconButton(
              onPressed: (() => {}),
              icon: const FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                size: 18,
              ),
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            autoCompleteSearch(value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {},
          child: const Text('Save',
              style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel',
              style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
        ),
      ],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );
  }

  Widget _confirmationDialog(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Publish Post',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Are you sure you want to add this post?',
        style: TextStyle(color: linkColor),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            confirmPost = true;
          },
          child: const Text('Post',
              style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel',
              style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
        ),
      ],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );
  }

  Widget _cTextField(
      {String? hint,
      int lines = 1,
      required TextEditingController controller,
      String? validator}) {
    return TextFormField(
      autofocus: false,
      maxLines: lines,
      controller: controller,
      keyboardType: TextInputType.text,
      validator: MultiValidator(
        [
          RequiredValidator(errorText: '$validator is required'),
          MinLengthValidator(lines == 1 ? 3 : 10,
              errorText:
                  '$validator must be at least ${lines == 1 ? 3 : 10} characters'),
        ],
      ),
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
