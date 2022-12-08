import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/components/profile_page/security_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SecuritySettings extends StatefulWidget {
  UserData user;
  VoidCallback toggleDrawer;

  SecuritySettings({Key? key, required this.user, required this.toggleDrawer})
      : super(key: key);

  @override
  _SecuritySettingsState createState() => _SecuritySettingsState();
}

class _SecuritySettingsState extends State<SecuritySettings> {
  bool verified = false;
  String providerId = '';

  @override
  void initState() {
    super.initState();
    getProvider();
  }

  void getProvider() {
    setState(() {
      verified = AccountControl.getCurrentUser().emailVerified;
      providerId = AccountControl.getCurrentUser().providerData[0].providerId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('Security Settings',
              style: TextStyle(
                color: linkColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                fontSize: 18,
              )),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: SizedBox(
                  width: 24,
                  child: IconButton(
                      onPressed: () {
                        widget.toggleDrawer();
                      },
                      icon: const Icon(FontAwesomeIcons.bars,
                          size: 20, color: linkColor))),
            )
          ],
          backgroundColor: primaryColor,
          elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  'AUTHENTICATION',
                  style: TextStyle(
                      color: textColor.withOpacity(0.4),
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              buildText(
                  label: 'Provider',
                  value: providerId.isEmpty
                      ? 'Loading...'
                      : providerId == 'google.com'
                          ? 'Google Account'
                          : 'Email Address',
                  icon: providerId.isEmpty
                      ? FontAwesomeIcons.google
                      : providerId == 'google.com'
                          ? FontAwesomeIcons.google
                          : FontAwesomeIcons.solidEnvelope),
              const SizedBox(height: 10),
              buildText(
                  label: 'Email',
                  value: widget.user.email,
                  icon: FontAwesomeIcons.solidEnvelope),
              if (!verified)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: primaryColor, width: 1.5)),
                    child: const Center(
                      child: Text(
                        'Your email address is not yet verified.',
                        style: TextStyle(color: linkColor),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 30),
                child: Text(
                  'SECURITY OPTIONS',
                  style: TextStyle(
                      color: textColor.withOpacity(0.4),
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              if (!verified)
                buildButton(
                    label: 'Verify Email Address',
                    onClick: () {
                      AccountControl.getCurrentUser()
                          .sendEmailVerification()
                          .whenComplete(() => {
                                ShoWInfo.showUpDialog(context,
                                    title: 'Email Verification',
                                    message:
                                        'An email has been sent to your email address, please check it to verify your account.',
                                    action1: 'Okay', btn1: () {
                                  Navigator.of(context).pop();
                                })
                              })
                          .onError((error, stackTrace) =>
                              ShoWInfo.showToast(error.toString(), 3));
                    }),
              if (!verified) const SizedBox(height: 10),
              buildButton(
                  label: 'Change Password',
                  onClick: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecurityOptions(
                            type: 1,
                            userId: widget.user.id!,
                          ),
                        ));
                  }),
              const SizedBox(height: 10),
              buildButton(
                  label: 'Update Email Address',
                  onClick: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecurityOptions(
                            type: 0,
                            userId: widget.user.id!,
                          ),
                        ));
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  width: double.infinity,
                  height: 90,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: primaryColor, width: 1.5)),
                  child: const Center(
                    child: Text(
                      'Note:\nThese options requires user to re-login, please login again before doing any of these actions.',
                      style: TextStyle(color: linkColor),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
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

  Widget buildText(
      {required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: Row(
        children: [
          Icon(
            icon,
            color: linkColor,
            size: 22,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            '$label: ',
            style:
                const TextStyle(color: linkColor, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(color: linkColor),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
