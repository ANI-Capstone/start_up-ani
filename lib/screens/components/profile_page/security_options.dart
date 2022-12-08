import 'package:ani_capstone/api/account_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/auth/log_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SecurityOptions extends StatefulWidget {
  int type;
  String userId;
  SecurityOptions({Key? key, required this.type, required this.userId})
      : super(key: key);

  @override
  _SecurityOptionsState createState() => _SecurityOptionsState();
}

class _SecurityOptionsState extends State<SecurityOptions> {
  List<String> type = ['Change Email Address', 'Change Password'];

  late List<TextEditingController> textController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    textController = List.generate(2, (i) => TextEditingController());
  }

  void updateEmail() async {
    final newEmail = textController[0].text.trim();

    try {
      await AccountControl.getCurrentUser().updateEmail(newEmail);

      AccountApi.updateEmail(userId: widget.userId, newEmail: newEmail)
          .whenComplete(() => {
                ShoWInfo.showToast(
                    'Your email has been update succesfully.', 3),
                Navigator.of(context).pop()
              });
    } on FirebaseAuthException catch (e) {
      ShoWInfo.showToast(e.toString(), 5);
      return null;
    }
  }

  void updatePassword() async {
    final newPassword = textController[0].text.trim();

    try {
      await AccountControl.getCurrentUser().updatePassword(newPassword);
      // ignore: use_build_context_synchronously
      return ShoWInfo.showUpDialog(context,
          title: 'Update Password',
          message:
              'You have successfully updated your password, please login again.',
          action1: 'Login', btn1: () {
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
                          'Logging out, please wait...',
                          style: TextStyle(fontFamily: 'Roboto'),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });

        AccountControl.logoutAccount(context);
      });
    } on FirebaseAuthException catch (e) {
      ShoWInfo.showToast(e.toString(), 5);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(FontAwesomeIcons.arrowLeft,
                  color: linkColor, size: 18)),
          title: Text(type[widget.type],
              style: const TextStyle(
                color: linkColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                fontSize: 18,
              )),
          backgroundColor: primaryColor,
          elevation: 0),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: widget.type == 0 ? changeEmail() : changePassword())),
    );
  }

  Widget changeEmail() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'New Email Address',
              style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600),
            ),
          ),
          TextFormField(
              autofocus: false,
              controller: textController[0],
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
                textController[0].text = value!;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                border: textFieldBorder,
              )),
          const SizedBox(
            height: 20,
          ),
          buildButton(
              label: 'Update Email',
              onClick: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  FocusManager.instance.primaryFocus?.unfocus();

                  updateEmail();
                }
              })
        ],
      ),
    );
  }

  Widget changePassword() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'New Password',
              style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600),
            ),
          ),
          TextFormField(
              autofocus: false,
              controller: textController[0],
              obscureText: true,
              validator: passwordValidator,
              onSaved: (value) {
                textController[0].text = value!;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                isDense: true,
                border: textFieldBorder,
              )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Confirm Password',
              style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600),
            ),
          ),
          TextFormField(
              autofocus: false,
              controller: textController[1],
              obscureText: true,
              validator: (value) {
                if (value!.isEmpty) {
                  return ("Re-type your password");
                }
                if (value != textController[0].text) {
                  return ("Password not match");
                }
                return null;
              },
              onSaved: (value) {
                textController[1].text = value!;
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                isDense: true,
                border: textFieldBorder,
              )),
          const SizedBox(
            height: 20,
          ),
          buildButton(
              label: 'Update Password',
              onClick: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  FocusManager.instance.primaryFocus?.unfocus();

                  updatePassword();
                }
              })
        ],
      ),
    );
  }

  Widget buildButton({required String label, required VoidCallback onClick}) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
          height: 40,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: primaryColor),
          child: Center(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)))),
    );
  }
}
