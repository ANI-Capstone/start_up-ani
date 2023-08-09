import 'dart:io';

import 'package:ani_capstone/api/account_api.dart';
import 'package:ani_capstone/api/firebase_filehost.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  UserData user;
  Function(int index) changeTab;
  VoidCallback getUserData;
  EditProfile(
      {Key? key,
      required this.user,
      required this.changeTab,
      required this.getUserData})
      : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late List<TextEditingController> textController;

  final _formKey = GlobalKey<FormState>();

  bool updatePic = false;

  final ImagePicker _picker = ImagePicker();
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    textController = List.generate(7, (i) => TextEditingController());
  }

  bool checkChange() {
    bool changed = false;
    for (int i = 0; i < textController.length; i++) {
      if (textController[i].text.trim().isNotEmpty) {
        changed = true;
        break;
      }
    }

    return changed;
  }

  void clearField() {
    setState(() {
      updatePic = false;
      for (var element in textController) {
        element.clear();
      }
    });
  }

  void uploadData() async {
    String? photoUrl;
    UserData? userdata;

    if (updatePic) {
      try {
        ShoWInfo.showToast('Please wait, uploading photo.', 3);
        await FirebaseStorageDb.changeProfilePic(
                userId: widget.user.id!, imageFile: pickedImage)
            .then((value) => {
                  ShoWInfo.showToast('Uploaded successfully.', 3),
                  photoUrl = value
                });
      } on FirebaseException catch (_) {
        ShoWInfo.showToast('Upload failed, unable to upload photo.', 3);
        return null;
      } on Exception catch (_) {
        ShoWInfo.showToast('Upload failed, unable to upload photo.', 3);
        return null;
      }
    }

    userdata = UserData(
        name: textController[0].text.isEmpty
            ? widget.user.name
            : textController[0].text.trim(),
        email: widget.user.email,
        photoUrl: updatePic ? photoUrl : widget.user.photoUrl,
        phone: textController[1].text.isEmpty
            ? widget.user.phone
            : textController[1].text.trim(),
        street: textController[2].text.isEmpty
            ? widget.user.street
            : textController[2].text.trim(),
        barangay: textController[3].text.isEmpty
            ? widget.user.barangay
            : textController[3].text.trim(),
        city: textController[4].text.isEmpty
            ? widget.user.city
            : textController[4].text.trim(),
        province: textController[5].text.isEmpty
            ? widget.user.province
            : textController[5].text.trim(),
        zipcode: textController[6].text.isEmpty
            ? widget.user.zipcode
            : int.parse(textController[6].text.trim()),
        userTypeId: widget.user.userTypeId,
        typeName: widget.user.typeName);

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
                      'Updating account, please wait...',
                      style: TextStyle(fontFamily: 'Roboto'),
                    )
                  ],
                ),
              ),
            ),
          );
        });

    AccountApi.updateUserData(userId: widget.user.id!, userData: userdata)
        .whenComplete(() => {
              ShoWInfo.showToast('Account updated successfully.', 3),
              Navigator.of(context).pop(),
              clearField(),
              widget.getUserData(),
              widget.changeTab(0)
            })
        .onError((error, stackTrace) => {
              Navigator.of(context).pop(),
              ShoWInfo.showToast('Failed, an error occured.', 3)
            });
  }

  void updateData() async {
    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();

    if (!checkChange() && !updatePic) {
      showUpDialog(context,
          title: 'Update Profile',
          message: "Fields are empty, no changes will be made to your profile.",
          action1: 'Okay', btn1: () {
        Navigator.of(context).pop();
      });
    } else {
      bool update = false;

      if (textController[1].text.trim().isNotEmpty) {
        final value = textController[1].text.trim();

        if (value.length < 11 ||
            !RegExp("^(?:[+0]9)?[0-9]{10,12}").hasMatch(value) ||
            RegExp("^[a-zA-Z+_.-]+@[a-zA-Z.-]+.[a-z]").hasMatch(value)) {
          return showUpDialog(context,
              title: 'Invalid Phone Number',
              message: 'Please input a valid phone number.',
              action1: 'Okay', btn1: () {
            Navigator.of(context).pop();
          });
        }
      }

      showUpDialog(context,
          title: 'Update Profile',
          message: "Are you sure you want to update your profile?",
          action1: 'Save Changes',
          btn1: () {
            Navigator.of(context).pop();
            update = true;
          },
          action2: 'Cancel',
          btn2: () {
            Navigator.of(context).pop();
          }).whenComplete(() => {
            if (update) {uploadData()}
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
          centerTitle: true,
          leading: GestureDetector(
              onTap: () {
                if (checkChange()) {
                  showUpDialog(context,
                      title: 'Unsaved Changes',
                      message: 'Are you sure you want to discard changes?',
                      action1: 'Discard',
                      btn1: () {
                        clearField();
                        Navigator.of(context).pop();
                        widget.changeTab(0);
                      },
                      action2: 'Cancel',
                      btn2: () {
                        Navigator.of(context).pop();
                      });
                } else {
                  widget.changeTab(0);
                }
              },
              child: const Icon(FontAwesomeIcons.xmark,
                  color: linkColor, size: 18)),
          title: const Text('Edit Profile',
              style: TextStyle(
                color: linkColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                fontSize: 18,
              )),
          actions: [
            GestureDetector(
              onTap: () {
                updateData();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(
                  FontAwesomeIcons.check,
                  size: 18,
                  color: linkColor,
                ),
              ),
            )
          ],
          backgroundColor: primaryColor,
          elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: defaultPadding),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 102,
                    height: 102,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                      child: CircleAvatar(
                          radius: 48,
                          backgroundColor: primaryColor,
                          backgroundImage: updatePic
                              ? Image.file(pickedImage!).image
                              : NetworkImage(
                                  widget.user.photoUrl!)),
                    ),
                  ),
                  if (updatePic)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          if (mounted) {
                            setState(() {
                              updatePic = false;
                            });
                          }
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Center(
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                  color: primaryColor, shape: BoxShape.circle),
                              child: const Center(
                                  child: Icon(
                                FontAwesomeIcons.rotateLeft,
                                size: 12,
                                color: linkColor,
                              )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: ((builder) => bottomSheet()),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Center(
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                                color: primaryColor, shape: BoxShape.circle),
                            child: const Center(
                                child: Icon(
                              FontAwesomeIcons.pen,
                              size: 14,
                              color: linkColor,
                            )),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BASIC INFO',
                      style: TextStyle(
                          color: textColor.withOpacity(0.4),
                          fontWeight: FontWeight.bold),
                    ),
                    builTextField(
                        label: 'Name',
                        hint: widget.user.name,
                        icon: FontAwesomeIcons.solidUser,
                        index: 0),
                    builTextField(
                        label: 'Phone Number',
                        hint: widget.user.phone,
                        icon: FontAwesomeIcons.phone,
                        index: 1),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'ADDRESS',
                      style: TextStyle(
                          color: textColor.withOpacity(0.4),
                          fontWeight: FontWeight.bold),
                    ),
                    builTextField(
                        label: 'Street',
                        hint: widget.user.street,
                        icon: FontAwesomeIcons.house,
                        index: 2),
                    builTextField(
                        label: 'Barangay',
                        hint: widget.user.barangay,
                        icon: FontAwesomeIcons.mountain,
                        index: 3),
                    builTextField(
                        label: 'Municipality/City',
                        hint: widget.user.city,
                        icon: FontAwesomeIcons.city,
                        index: 4),
                    builTextField(
                        label: 'Province',
                        hint: widget.user.province,
                        icon: FontAwesomeIcons.mountainCity,
                        index: 5),
                    builTextField(
                        label: 'Zip Code',
                        hint: '${widget.user.zipcode}',
                        icon: Icons.markunread_mailbox_rounded,
                        index: 6)
                  ],
                ))
          ]),
        ),
      ),
    );
  }

  TextFormField builTextField(
      {required String label,
      required String hint,
      required IconData icon,
      required int index}) {
    var inputType = TextInputType.text;

    if (index == 1) {
      inputType = TextInputType.phone;
    } else if (index == 6) {
      inputType = TextInputType.number;
    }

    return TextFormField(
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(fontSize: 15),
      keyboardType: inputType,
      maxLength: index == 1 ? 11 : null,
      controller: textController[index],
      inputFormatters:
          index == 1 ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
          iconColor: linkColor,
          isCollapsed: false,
          icon: Icon(
            icon,
            size: index == 6 ? 20 : 18,
            color: linkColor,
          ),
          hintText: hint,
          labelText: label,
          labelStyle: const TextStyle(color: linkColor),
          hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
          focusColor: linkColor,
          floatingLabelBehavior: FloatingLabelBehavior.always),
      onSaved: (String? value) {
        textController[index].text = value!;
      },
    );
  }

  Future showUpDialog(BuildContext context,
      {required String title,
      required String message,
      required String action1,
      String? action2 = '',
      required VoidCallback btn1,
      VoidCallback? btn2}) {
    Widget button1 = TextButton(
      onPressed: () {
        btn1();
      },
      child: Text(action1,
          style:
              const TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
    );

    Widget button2 = action2!.isNotEmpty
        ? TextButton(
            onPressed: btn2!,
            child: Text(action2,
                style: const TextStyle(
                    color: linkColor, fontWeight: FontWeight.bold)),
          )
        : Container();

    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 15),
      ),
      actions: action2.isNotEmpty ? [button1, button2] : [button1],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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

  Future pickImages(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      setState(() {
        pickedImage = File(image!.path);
        updatePic = true;
      });
    } on Exception catch (e) {
      ShoWInfo.errorAlert(context, e.toString(), 5);
    }
    if (pickedImage == null) return;
  }
}
