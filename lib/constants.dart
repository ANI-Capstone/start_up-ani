import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';

const primaryColor = Color(0xFFC6D8AF);
const textColor = Color(0xFF121212);
const backgroundColor = Colors.white;
const redColor = Color(0xFFE85050);
const borderColor = Color(0xFF121212);
const linkColor = Color(0xFF315300);
const userBgColor = Color(0xFFF5F5F5);
const starColor = Color(0xFFFFB800);
const badgeColor = Color(0xFFFF8C00);
const plusColor = Color(0xFFD5D5D5);
const unLikeColor = Color(0xFFB5B5B5);
const likeColor = Color(0xFF315300);
final bannerBgColor = const Color(0xFFC6D8AF).withOpacity(0.4);
final pendingColor = const Color(0xFFFFB800).withOpacity(0.5);
const acceptedColor = Color(0xFFC6D8AF);
const deniedColor = Color(0xFFF24537);

const defaultPadding = 32.0;

const userImage = AssetImage('assets/images/user.png');

OutlineInputBorder textFieldBorder = OutlineInputBorder(
  borderSide: BorderSide(
    color: borderColor.withOpacity(0.1),
  ),
  borderRadius: BorderRadius.circular(15),
);

OutlineInputBorder enabledtextFieldBorder = OutlineInputBorder(
  borderSide: BorderSide(
    color: linkColor.withOpacity(0.5),
  ),
  borderRadius: BorderRadius.circular(15),
);

InputDecoration fieldDecoration = InputDecoration(
  fillColor: Colors.white,
  border: OutlineInputBorder(
      borderSide: BorderSide(
        color: linkColor.withOpacity(0.5),
      ),
      borderRadius: BorderRadius.circular(15)),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: const BorderSide(
      color: linkColor,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: const BorderSide(
      color: linkColor,
    ),
  ),
);

final passwordValidator = MultiValidator(
  [
    RequiredValidator(errorText: 'Password is required'),
    MinLengthValidator(8, errorText: 'Password must be at least 8 digits long'),
  ],
);

const double medium = 50;
const double small = 40;

class ShoWInfo {
  ShoWInfo._();
  static errorAlert(BuildContext context, String message, int seconds) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: seconds),
      backgroundColor: redColor,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    ));
  }

  static successAlert(BuildContext context, String message, int seconds) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: seconds),
      backgroundColor: Colors.green,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    ));
  }

  static showToast(String message, int? seconds) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: seconds == null
            ? Toast.LENGTH_SHORT
            : seconds < 3
                ? Toast.LENGTH_SHORT
                : Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: linkColor,
        fontSize: 14);
  }

  static processAlert(BuildContext context, String message, int seconds) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: seconds),
      backgroundColor: linkColor,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    ));
  }

  static showLoadingDialog(BuildContext context, {required String message}) {
    showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The loading indicator
                    const CircularProgressIndicator(
                      color: primaryColor,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // Some text
                    Text(
                      message,
                      style: const TextStyle(fontFamily: 'Roboto'),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  static showAlertDialog(BuildContext context,
      {required String title,
      required String message,
      required String btnText,
      required VoidCallback onClick}) {
    // set up the button
    Widget okButton = TextButton(
      onPressed: onClick,
      child: Text(btnText,
          style:
              const TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        okButton,
      ],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static Future showUpDialog(BuildContext context,
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
}

class CustomButton {
  static customIconButton(BuildContext context,
      {required size,
      required height,
      required icon,
      required label,
      required text}) {
    return SizedBox(
        width: size.width,
        height: small,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: backgroundColor,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: <Widget>[
                  Icon(
                    icon,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Flexible(
                    child: SizedBox(
                      width: (size.width - 30),
                      child: Text.rich(TextSpan(
                          text: '$label:  ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: linkColor,
                              overflow: TextOverflow.ellipsis),
                          children: [
                            TextSpan(
                                text: (text.length < 30)
                                    ? text
                                    : '${text.toString().characters.take(27)}...',
                                style: TextStyle(
                                    color: linkColor.withOpacity(0.8),
                                    overflow: TextOverflow.ellipsis))
                          ])),
                    ),
                  )
                ],
              ),
            )));
  }
}
