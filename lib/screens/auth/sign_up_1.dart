// ignore_for_file: unnecessary_new, unnecessary_const, prefer_const_constructors, avoid_unnecessary_containers

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/providers/google_sign_in.dart';
import 'package:ani_capstone/screens/auth/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

// ignore: use_key_in_widget_constructors
class SignUp1 extends StatelessWidget {
  // It's time to validat the text field
  final _formKey = GlobalKey<FormState>();

  final emailEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
        autofocus: false,
        controller: emailEditingController,
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
          emailEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          border: textFieldBorder,
        ));

    final passwordField = TextFormField(
        autofocus: false,
        controller: passwordEditingController,
        obscureText: true,
        validator: passwordValidator,
        onSaved: (value) {
          passwordEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          border: textFieldBorder,
        ));

    final signUpButton = Material(
      borderRadius: BorderRadius.circular(15),
      color: primaryColor,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
            }
            // signUp(emailEditingController.text, passwordEditingController.text);
          },
          child: Text(
            "Proceed",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          toolbarHeight: 45,
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: Stack(
          children: [
            Container(
              height: size.height * 0.10,
              color: primaryColor,
            ),
            Positioned(
                child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: const Radius.circular(40))),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 50),
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
                                  SvgPicture.asset(
                                    "assets/icons/back.svg",
                                  ),
                                ],
                              ),
                            ),
                            Form(
                              key: _formKey,
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
                                  SizedBox(height: 40),
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
                                              Provider.of<GoogleSignInProvider>(
                                                  context,
                                                  listen: false);

                                          provider.googleLogin();
                                        },
                                        child: SvgPicture.asset(
                                          "assets/icons/google.svg",
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      GestureDetector(
                                        onTap: () {
                                          print("onTap called.");
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
                                      TextButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SignInScreen(),
                                            )),
                                        child: Text(
                                          "Log In!",
                                          style: TextStyle(
                                              color: linkColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))),
          ],
        )));
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
