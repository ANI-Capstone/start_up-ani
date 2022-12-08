import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/providers/google_provider.dart';
import 'package:ani_capstone/screens/components/profile_page/edit_profile.dart';
import 'package:ani_capstone/screens/components/profile_page/my_profile.dart';
import 'package:ani_capstone/screens/components/profile_page/profile_management.dart';
import 'package:ani_capstone/screens/components/profile_page/security_settings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';

class UserProfile extends StatefulWidget {
  UserData user;
  VoidCallback getUserData;
  UserProfile({Key? key, required this.user, required this.getUserData})
      : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    late Widget screenCurrent;

    return SimpleHiddenDrawer(
      withShadow: false,
      typeOpen: TypeOpen.FROM_RIGHT,
      slidePercent: 70,
      contentCornerRadius: 25,
      menu: Menu(),
      screenSelectedBuilder: (position, controller) {
        switch (position) {
          case 0:
            screenCurrent = MyProfile(
              user: widget.user,
              toggleDrawer: () {
                controller.toggle();
              },
            );

            break;
          case 1:
            screenCurrent = ProfileAction(
              user: widget.user,
              toggleDrawer: () {
                controller.toggle();
              },
              getUserData: () {
                widget.getUserData();
              },
            );
            break;
          case 2:
            screenCurrent = SecuritySettings(
                user: widget.user,
                toggleDrawer: () {
                  controller.toggle();
                });
            break;
        }

        return SizedBox(child: screenCurrent);
      },
    );
  }
}

class Menu extends StatefulWidget {
  Menu({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late SimpleHiddenDrawerController controller;

  int currentIndex = 0;

  @override
  void didChangeDependencies() {
    controller = SimpleHiddenDrawerController.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(left: size.width * 0.3),
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: Colors.white,
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildLabel(
                  FontAwesomeIcons.solidUser, 'My Profile', 0, currentIndex,
                  onTap: () {
                setState(() {
                  currentIndex = 0;
                });
                controller.setSelectedMenuPosition(0);
              }),
              buildLabel(
                  FontAwesomeIcons.edit, 'Manage Profile', 1, currentIndex,
                  onTap: () {
                setState(() {
                  currentIndex = 1;
                });
                controller.setSelectedMenuPosition(1);
              }),
              buildLabel(
                  FontAwesomeIcons.gear, 'Security Settings', 2, currentIndex,
                  onTap: () {
                setState(() {
                  currentIndex = 2;
                });
                controller.setSelectedMenuPosition(2);
              }),
              buildLabel(FontAwesomeIcons.lock, 'Logout', 3, currentIndex,
                  onTap: () {
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
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
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLabel(IconData icon, String label, int index, int currentIndex,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15, left: 30),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: linkColor,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                      color: linkColor,
                      fontSize: 16,
                      fontWeight: currentIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              ),
              if (currentIndex == index)
                Container(
                  width: 5,
                  height: 22,
                  decoration: const BoxDecoration(color: likeColor),
                )
            ],
          ),
        ),
      ),
    );
  }
}
