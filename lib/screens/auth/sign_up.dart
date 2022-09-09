// ignore_for_file: unnecessary_new, unnecessary_const, prefer_const_constructors, avoid_unnecessary_containers, use_build_context_synchronously

import 'dart:io';

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/providers/email_provider.dart';
import 'package:ani_capstone/api/firebase_filehost.dart';
import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/auth/log_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/facebook_provider.dart';
import '../home_page.dart';

class SignUp extends StatefulWidget {
  final String? userId;
  final String? userEmail;
  final int? index;
  const SignUp({Key? key, this.userId, this.userEmail, this.index})
      : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int screenIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.index != null && widget.userId != null) {
      screenIndex = widget.index as int;
      _email.text = widget.userEmail as String;
      authID = widget.userId;
    }
  }

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  final _email = new TextEditingController();
  final _password = new TextEditingController();
  final _cpassword = new TextEditingController();
  final _phone = new TextEditingController();
  final _street = new TextEditingController();
  final _barangay = new TextEditingController();
  final _city = new TextEditingController();
  final _province = new TextEditingController();
  final _zipCode = new TextEditingController();
  final _firstName = new TextEditingController();
  final _lastName = new TextEditingController();
  final _mi = new TextEditingController();

  String? authID;
  String? photoURL;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  var _autoValidate = AutovalidateMode.disabled;

  Widget _signUp1(BuildContext context) {
    final emailField = TextFormField(
        autofocus: false,
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Email is required");
          }
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Please enter a valid email");
          }
          return null;
        },
        onSaved: (value) {
          _email.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: textFieldBorder,
        ));

    final passwordField = TextFormField(
        autofocus: false,
        controller: _password,
        obscureText: true,
        validator: passwordValidator,
        onSaved: (value) {
          _password.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          isDense: true,
          border: textFieldBorder,
        ));

    final cpasswordField = TextFormField(
        autofocus: false,
        controller: _cpassword,
        obscureText: true,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Re-type your password");
          }
          if (value != _password.text) {
            return ("Password not match");
          }
          return null;
        },
        onSaved: (value) {
          _cpassword.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          isDense: true,
          border: textFieldBorder,
        ));

    final signUpButton = SizedBox(
        height: small,
        child: Material(
          borderRadius: BorderRadius.circular(15),
          color: primaryColor,
          child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {
                if (_formKey1.currentState!.validate()) {
                  _formKey1.currentState!.save();

                  FocusManager.instance.primaryFocus?.unfocus();

                  EmailProvider.createAccountEmail(context,
                          email: _email.text, password: _password.text)
                      .then((value) {
                    if ((value.toString().length > 1)) {
                      setState(() {
                        screenIndex = 1;
                        authID = value;
                      });
                    }
                  });
                } else {
                  setState(
                      () => _autoValidate = AutovalidateMode.onUserInteraction);
                }
              },
              child: Text(
                "Proceed",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ));

    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          toolbarHeight: 45,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              height: size.height * 0.10,
              color: primaryColor,
            ),
            Positioned(
                child: Container(
                    height: size.height * 0.90,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: const Radius.circular(40))),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: SingleChildScrollView(
                            child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "SIGN UP",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            Form(
                              key: _formKey1,
                              autovalidateMode: _autoValidate,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 45),
                                  TextFieldName(text: "Email"),
                                  emailField,
                                  SizedBox(height: 20),
                                  TextFieldName(text: "Password"),
                                  passwordField,
                                  SizedBox(height: 20),
                                  TextFieldName(text: "Confirm Password"),
                                  cpasswordField,
                                  SizedBox(height: 30),
                                  signUpButton,
                                  SizedBox(height: 40),
                                  Container(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Divider(
                                                thickness: 1.5,
                                                color: textColor
                                                    .withOpacity(0.1))),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    textColor.withOpacity(0.2)),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(3),
                                            child: Text('OR',
                                                style: TextStyle(
                                                    color: textColor
                                                        .withOpacity(0.2))),
                                          ),
                                        ),
                                        Expanded(
                                            child: Divider(
                                                thickness: 1.5,
                                                color: textColor
                                                    .withOpacity(0.1))),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          final provider =
                                              Provider.of<GoogleProvider>(
                                                  context,
                                                  listen: false);

                                          provider
                                              .googleSignin(context)
                                              .then((value) => {
                                                    if (value != null)
                                                      {
                                                        setState(
                                                          () {
                                                            _email.text =
                                                                value[0];
                                                            authID = value[1];
                                                            photoURL = value[2];
                                                            screenIndex = 1;
                                                          },
                                                        )
                                                      }
                                                  });
                                        },
                                        child: SvgPicture.asset(
                                          "assets/icons/google.svg",
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      GestureDetector(
                                        onTap: () {
                                          FacebookProvider.signUpFacebook(
                                                  context)
                                              .then((userData) => {
                                                    if (userData != null)
                                                      {
                                                        setState(() => {
                                                              photoURL = userData[
                                                                          0][
                                                                      'picture']
                                                                  [
                                                                  'data']['url'],
                                                              _email.text =
                                                                  userData[0]
                                                                      ['email'],
                                                              authID =
                                                                  userData[1],
                                                              screenIndex = 1
                                                            })
                                                      }
                                                  });
                                        },
                                        child: SvgPicture.asset(
                                          "assets/icons/facebook.svg",
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Already a user?"),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => LogIn(),
                                            )),
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(50, 30),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            alignment: Alignment.centerLeft),
                                        child: Text(
                                          "Log In",
                                          style: TextStyle(
                                              color: linkColor,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 75),
                                ],
                              ),
                            ),
                          ],
                        )),
                      ),
                    ))),
          ],
        ));
  }

  Widget _signUp2(BuildContext context) {
    final phoneField = TextFormField(
        autofocus: false,
        maxLength: 11,
        controller: _phone,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value!.isEmpty) {
            return ("Phone enter phone number");
          }
          if (!RegExp("^(?:[+0]9)?[0-9]{10,12}").hasMatch(value)) {
            return ("Please enter a valid phone number");
          }
          if (RegExp("^[a-zA-Z+_.-]+@[a-zA-Z.-]+.[a-z]").hasMatch(value)) {
            return ("Please enter a valid phone number");
          }
          if (value.length < 11) {
            return ("Please enter a valid phone number");
          }

          return null;
        },
        onSaved: (value) {
          _phone.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: textFieldBorder,
        ));

    final streetField = TextFormField(
        autofocus: false,
        controller: _street,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Type n/a if none");
          }
          return null;
        },
        onSaved: (value) {
          _street.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: textFieldBorder,
        ));

    final barangayField = TextFormField(
        autofocus: false,
        controller: _barangay,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return ("This field is required");
          }
          return null;
        },
        onSaved: (value) {
          _barangay.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: textFieldBorder,
        ));

    final cityField = TextFormField(
        autofocus: false,
        controller: _city,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return ("This field is required");
          }
          return null;
        },
        onSaved: (value) {
          _city.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: textFieldBorder,
        ));

    final provinceField = TextFormField(
        autofocus: false,
        controller: _province,
        keyboardType: TextInputType.text,
        validator: (value) {
          if (value!.isEmpty) {
            return ("This field is required");
          }
          return null;
        },
        onSaved: (value) {
          _province.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: textFieldBorder,
        ));

    final zipCodeField = TextFormField(
        controller: _zipCode,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value!.isEmpty) {
            return ("This field is required");
          }
          return null;
        },
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSaved: (value) {
          _zipCode.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: textFieldBorder,
        ));

    final signUpButton = SizedBox(
        height: small,
        child: Material(
          borderRadius: BorderRadius.circular(15),
          color: primaryColor,
          child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                if (_phone.text.isEmpty &&
                    _street.text.isEmpty &&
                    _barangay.text.isEmpty &&
                    _city.text.isEmpty &&
                    _city.text.isEmpty &&
                    _province.text.isEmpty &&
                    _zipCode.text.isEmpty) {
                  ShoWInfo.showAlertDialog(context,
                      title: 'Missing Fields',
                      message: 'Please input all the required fields.',
                      btnText: 'OK', onClick: () {
                    Navigator.of(context).pop();
                  });
                  return;
                }

                if (_formKey2.currentState!.validate()) {
                  _formKey2.currentState!.save();

                  setState(() {
                    screenIndex = 2;
                  });
                }
                // signUp(_email.text, _password.text);
              },
              child: Text(
                "Proceed",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ));

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        toolbarHeight: 45,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            height: size.height * 0.10,
            color: primaryColor,
          ),
          Positioned(
              child: Container(
                  width: size.width,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: const Radius.circular(40))),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: SingleChildScrollView(
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "SIGN UP",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Form(
                              key: _formKey2,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 25),
                                  TextFieldName(text: "Phone Number"),
                                  phoneField,
                                  SizedBox(height: 10),
                                  Text(
                                    'ADDRESS',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  TextFieldName(text: "Street"),
                                  streetField,
                                  SizedBox(height: 10),
                                  TextFieldName(text: "Barangay"),
                                  barangayField,
                                  SizedBox(height: 10),
                                  TextFieldName(text: "City/Municipality"),
                                  cityField,
                                  SizedBox(height: 10),
                                  TextFieldName(text: "Province"),
                                  provinceField,
                                  SizedBox(height: 10),
                                  TextFieldName(text: "Zip Code"),
                                  zipCodeField,
                                  SizedBox(height: 30),
                                  signUpButton,
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))),
        ],
      ),
    );
  }

  Widget _signUp3(BuildContext context) {
    final firstNameField = TextFormField(
        autofocus: false,
        controller: _firstName,
        keyboardType: TextInputType.name,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Firstname is required");
          }
          return null;
        },
        onSaved: (value) {
          _firstName.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          border: textFieldBorder,
        ));

    final lastNameField = TextFormField(
        autofocus: false,
        controller: _lastName,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Lastname is required");
          }
          return null;
        },
        onSaved: (value) {
          _lastName.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          isDense: true,
          border: textFieldBorder,
        ));

    final middleNameField = TextFormField(
        autofocus: false,
        controller: _mi,
        onSaved: (value) {
          _mi.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          isDense: true,
          border: textFieldBorder,
        ));

    final signUpButton = SizedBox(
        height: small,
        child: Material(
          borderRadius: BorderRadius.circular(15),
          color: primaryColor,
          child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {
                if (_formKey3.currentState!.validate()) {
                  _formKey3.currentState!.save();

                  FocusManager.instance.primaryFocus?.unfocus();

                  if (photoURL == null) {
                    ShoWInfo.errorAlert(
                        context, 'Please add your profile photo.', 5);

                    return;
                  }

                  var name = "${_firstName.text} ${_mi.text} ${_lastName.text}";

                  var userData = UserData(
                      id: authID!.trim(),
                      name: name.trim(),
                      email: _email.text.trim(),
                      phone: _phone.text.trim(),
                      street: _street.text.trim(),
                      barangay: _barangay.text.trim(),
                      city: _city.text.trim(),
                      province: _province.text.trim(),
                      zipcode: int.parse(_zipCode.text.trim()),
                      photoUrl: photoURL,
                      userTypeId: 0,
                      typeName: '');

                  FirebaseFirestoreDb.addAccount(context, userData)
                      .then((value) => {
                            if (value == 'Success')
                              {
                                ShoWInfo.showAlertDialog(context,
                                    title: 'ANI Account',
                                    message:
                                        'Your account has been created successfully.',
                                    btnText: 'Continue', onClick: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(),
                                      ));
                                })
                              }
                          });
                } else {
                  setState(
                      () => _autoValidate = AutovalidateMode.onUserInteraction);
                }
              },
              child: Text(
                "Sign Up",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ));

    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          toolbarHeight: 45,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Container(
              height: size.height * 0.10,
              color: primaryColor,
            ),
            Positioned(
                child: Container(
                    height: size.height * 0.90,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: const Radius.circular(40))),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      child: SingleChildScrollView(
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "SIGN UP",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  GestureDetector(
                                      onTap: () => setState(() {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            screenIndex = 1;
                                          }),
                                      child: SvgPicture.asset(
                                        "assets/icons/back.svg",
                                      ))
                                ],
                              ),
                            ),
                            Form(
                              key: _formKey3,
                              autovalidateMode: _autoValidate,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 30),
                                  Center(
                                    child: Column(
                                      children: [
                                        InkWell(
                                          child: CircleAvatar(
                                            backgroundColor: linkColor,
                                            radius: 70,
                                            child: CircleAvatar(
                                              radius: 68,
                                              backgroundColor: Colors.white,
                                              backgroundImage: photoURL != null
                                                  ? NetworkImage(photoURL!)
                                                  : AssetImage(
                                                          'assets/images/user.png')
                                                      as ImageProvider,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5),
                                            child: TextButton.icon(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder: ((builder) =>
                                                      bottomSheet()),
                                                );
                                              },
                                              icon: Icon(
                                                FontAwesomeIcons.camera,
                                                size: 16.0,
                                                color: linkColor,
                                              ),
                                              label: Text(
                                                'Edit Photo',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: textColor,
                                                ),
                                              ),
                                            ))
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  TextFieldName(text: "Firstname"),
                                  firstNameField,
                                  SizedBox(height: 20),
                                  TextFieldName(text: "Lastname"),
                                  lastNameField,
                                  SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: defaultPadding / 3),
                                    child: Text.rich(TextSpan(
                                        text: 'Middle Initial ',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: textColor),
                                        children: [
                                          TextSpan(
                                              text: '(Optional)',
                                              style: TextStyle(
                                                  color: textColor
                                                      .withOpacity(0.5)))
                                        ])),
                                  ),
                                  middleNameField,
                                  SizedBox(height: 35),
                                  signUpButton,
                                  SizedBox(height: 40)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )))),
          ],
        ));
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "Choose your photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera, color: linkColor),
              onPressed: () {
                Navigator.pop(context);
                takePhoto(ImageSource.camera);
              },
              label: Text("Camera", style: TextStyle(color: textColor)),
            ),
            SizedBox(
              width: 20,
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: linkColor),
              onPressed: () {
                Navigator.pop(context);
                takePhoto(ImageSource.gallery);
              },
              label: Text("Gallery", style: TextStyle(color: textColor)),
            ),
          ])
        ],
      ),
    );
  }

  Future takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) return;

    final tempImage = File(pickedFile.path);

    FirebaseStorageDb.uploadImage(context,
            userId: authID.toString(), path: 'image-url', imageFile: tempImage)
        .then((value) => {
              setState(() {
                if (value != null) {
                  _imageFile = tempImage;
                  photoURL = value;
                }
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    final signUpScreens = [
      _signUp1(context),
      _signUp2(context),
      _signUp3(context)
    ];

    return Scaffold(
        body: IndexedStack(
      index: screenIndex,
      children: signUpScreens,
    ));
  }
}

class TextFieldName extends StatelessWidget {
  const TextFieldName({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding / 3),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}
