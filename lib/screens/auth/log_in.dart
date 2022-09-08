// ignore_for_file: unnecessary_new, unnecessary_const, prefer_const_constructors, avoid_unnecessary_containers

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/providers/email_provider.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/auth/sign_up.dart';
import 'package:ani_capstone/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

// ignore: use_key_in_widget_constructors
class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  // It's time to validat the text field
  final _formKey = GlobalKey<FormState>();

  final _email = new TextEditingController();

  final _password = new TextEditingController();

  bool rememberMe = false;

  final textFieldFocusNode = FocusNode();
  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
      if (textFieldFocusNode.hasPrimaryFocus) {
        return;
      } // If focus is on text field, dont unfocus
      textFieldFocusNode.canRequestFocus =
          false; // Prevents focus if tap on eye
    });
  }

  @override
  Widget build(BuildContext context) {
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
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          border: textFieldBorder,
        ));

    final passwordField = TextFormField(
        autofocus: false,
        controller: _password,
        obscureText: _obscured,
        validator: passwordValidator,
        onSaved: (value) {
          _password.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          border: textFieldBorder,
          suffixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            child: IconButton(
              onPressed: _toggleObscured,
              icon: Icon(
                _obscured
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
              ),
            ),
          ),
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

              EmailProvider.loginAccountEmail(context,
                      email: _email.text, password: _password.text)
                  .then((value) => {
                        if (value != null)
                          {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ))
                          }
                      });
            }
            // signUp(_email.text, _password.text);
          },
          child: Text(
            "Log In",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );

    Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          toolbarHeight: 45,
          automaticallyImplyLeading: false,
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
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 50),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "LOG IN",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline5!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 45),
                                  TextFieldName(text: "Email"),
                                  emailField,
                                  SizedBox(height: 20),
                                  TextFieldName(text: "Password"),
                                  passwordField,
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 2, right: 8),
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: Checkbox(
                                                  value: rememberMe,
                                                  checkColor: Colors.white,
                                                  activeColor: linkColor,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      rememberMe = value!;
                                                    });
                                                  },
                                                  side: BorderSide(
                                                      width: 1,
                                                      color: textColor
                                                          .withOpacity(0.5)),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2)),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Remember me?',
                                              style: TextStyle(fontSize: 12),
                                            )
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => {},
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(50, 30),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            alignment: Alignment.centerLeft),
                                        child: Text(
                                          "Forgot Password?",
                                          style: TextStyle(
                                            color: linkColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
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
                                              .googleLogin(context)
                                              .then((value) => {
                                                    if (value != null)
                                                      {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      HomePage(),
                                                            ))
                                                      }
                                                    else
                                                      {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      LogIn(),
                                                            ))
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
                                          // FacebookSignInProvider
                                          //     .loginFacebook();
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
                                      Text("Don't have an account?",
                                          style: TextStyle(fontSize: 14)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => SignUp(),
                                            )),
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size(50, 30),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            alignment: Alignment.centerLeft),
                                        child: Text(
                                          "Sign Up",
                                          style: TextStyle(
                                              color: linkColor,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline),
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
