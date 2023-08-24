import 'dart:io';

import 'package:ani_capstone/api/firebase_filehost.dart';
import 'package:ani_capstone/api/product_post_api.dart';
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

class UserPost extends StatefulWidget {
  UserData user;
  UserPost({Key? key, required this.user}) : super(key: key);

  @override
  State<UserPost> createState() => _UserPostState();
}

class _UserPostState extends State<UserPost> {
  UserData? user;
  String? value1;
  String? value2;

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
  List<File>? pickedImages = [];

  var _autoValidate = AutovalidateMode.disabled;

  bool confirmPost = false;

  @override
  void initState() {
    super.initState();

    user = widget.user;

    // Prediction prediction = await PlacesAutocomplete.show(
    //         context: context,
    //         apiKey: API_KEY,
    //         mode: Mode.fullscreen, // Mode.overlay
    //         language: "en",
    //         components: [Component(Component.country, "pk")]);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);

    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var items1 = ['Kilogram', 'Gram', 'Pound'];
    var items2 = ['Default Address', 'Locate New Address'];

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Center(
              child: Text('CREATE POST',
                  style: TextStyle(
                    color: linkColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  )),
            ),
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
                          Image.network(user?.photoUrl as String).image),
                  const SizedBox(width: 10),
                  Text(
                    user?.name as String,
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const Expanded(child: SizedBox(width: 1)),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (_formKey.currentState!.validate()) {
                          if (productUnit == null) {
                            ShoWInfo.errorAlert(context,
                                "Please add a unit for your product post.", 5);
                            return;
                          } else if (location == null) {
                            ShoWInfo.errorAlert(context,
                                "Please specify your product location.", 5);
                            return;
                          } else if (pickedImages!.isEmpty) {
                            ShoWInfo.errorAlert(
                                context,
                                "Please add atleast one photo of your product.",
                                5);
                            return;
                          } else {
                            _formKey.currentState!.save();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return _confirmationDialog(context);
                              },
                            ).then((value) {
                              if (confirmPost) {
                                User newUser = User(
                                    userId: user!.id,
                                    name: user!.name,
                                    photoUrl: user!.photoUrl!);

                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) {
                                      return Dialog(
                                        // The background color
                                        backgroundColor: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(30))),
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
                                                  style: TextStyle(
                                                      fontFamily: 'Roboto'),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });

                                FirebaseStorageDb.uploadPostImages(
                                        userId: user!.id!,
                                        images: pickedImages!)
                                    .then((imgUrls) =>
                                        ProductPost.uploadPost(context,
                                            post: Post(
                                              publisher: newUser,
                                              postedAt: DateTime.now(),
                                              name: _productName.text.trim(),
                                              description: _productDescription
                                                  .text
                                                  .trim(),
                                              price: double.parse(
                                                  _productPrice.text.trim()),
                                              unit: productUnit!,
                                              location:
                                                  _newLocation.text.trim(),
                                              images: imgUrls,
                                            )).then((value) {
                                          if (value) {
                                            Navigator.of(context).pop();
                                            ShoWInfo.successAlert(
                                                context,
                                                'Your product has been posted successfully.',
                                                5);
                                            setState(() {
                                              _formKey.currentState!.reset();
                                              _productName.text = '';
                                              _productDescription.text = '';
                                              _productPrice.text = '';
                                              _newLocation.text = '';
                                              pickedImages!.clear();
                                              productUnit = null;
                                              location = null;
                                            });
                                          } else {
                                            Navigator.of(context).pop();
                                            ShoWInfo.errorAlert(
                                                context,
                                                'Failed to upload your post, please try again later.',
                                                5);
                                          }
                                        }));

                                confirmPost = false;
                              }
                            });
                          }
                        } else {
                          setState(() {
                            _autoValidate = AutovalidateMode.onUserInteraction;
                          });
                          ShoWInfo.errorAlert(context,
                              'Please fill all the required fields.', 5);
                        }
                      },
                      child: const Text('POST',
                          style: TextStyle(
                              color: linkColor, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
                Form(
                  key: _formKey,
                  autovalidateMode: _autoValidate,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      _cTextField(
                          controller: _productName,
                          hint: 'Product name',
                          validator: 'Product name'),
                      const SizedBox(
                        height: 20,
                      ),
                      _cTextField(
                          controller: _productDescription,
                          hint: 'Type product details',
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
                                decoration: const InputDecoration(
                                    isDense: true,
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: primaryColor, width: 1.5)),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 5),
                                    hintText: 'Price',
                                    hintStyle: TextStyle(color: primaryColor),
                                    prefixIconConstraints: BoxConstraints(
                                        minWidth: 23, maxHeight: 20),
                                    suffixIconConstraints: BoxConstraints(
                                        minWidth: 23, maxHeight: 20),
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.zero,
                                      child: FaIcon(FontAwesomeIcons.pesoSign,
                                          color: primaryColor, size: 16),
                                    ),
                                    suffixIcon: Padding(
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
            value: location,
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
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _cInputDialog(context);
                  },
                );
              } else {
                _newLocation.text =
                    '${user?.street}, ${user?.barangay}, ${user?.city}, ${user?.province}, ${user?.zipcode}';
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
              onPressed: (() {}),
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
    return pickedImages == null ? _emptyPhoto(context) : _postImages(context);
  }

  Widget _postImages(BuildContext context) {
    if (pickedImages!.length == 1) {
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
    } else if (pickedImages!.length >= 2) {
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
                  child: pickedImages!.length < 3
                      ? Image.file(
                          pickedImages![index],
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.file(
                              pickedImages![index],
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
                                  child: Text('+${pickedImages!.length - 2}',
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
                      pickedImages!.removeAt(index);
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
                  pickedImages![index],
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
                    pickedImages!.removeAt(index);
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
            pickedImages!.addAll(images.map((img) => File(img.path)).toList());
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(source: source);
        setState(() {
          pickedImages!.add(File(image!.path));
        });
      }
    } on Exception catch (e) {
      ShoWInfo.errorAlert(context, e.toString(), 5);
    }
    if (pickedImages == null) return;
  }
}
