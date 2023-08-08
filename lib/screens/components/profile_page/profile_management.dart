import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/screens/components/profile_page/edit_profile.dart';
import 'package:ani_capstone/screens/components/widgets/image_preview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileAction extends StatefulWidget {
  UserData user;
  VoidCallback toggleDrawer;
  VoidCallback getUserData;
  ProfileAction(
      {super.key,
      required this.user,
      required this.toggleDrawer,
      required this.getUserData});

  @override
  State<ProfileAction> createState() => _ProfileActionState();
}

class _ProfileActionState extends State<ProfileAction> {
  int tabIndex = 0;

  void changeTab(int index) {
    if (mounted) {
      setState(() {
        tabIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: tabIndex,
      children: [
        ProfileManagement(
          user: widget.user,
          toggleDrawer: widget.toggleDrawer,
          changeTab: (int index) {
            changeTab(index);
          },
        ),
        EditProfile(
          user: widget.user,
          changeTab: (int index) {
            changeTab(index);
          },
          getUserData: () {
            widget.getUserData();
          },
        )
      ],
    );
  }
}

class ProfileManagement extends StatelessWidget {
  UserData user;
  VoidCallback toggleDrawer;
  Function(int index) changeTab;
  ProfileManagement(
      {Key? key,
      required this.user,
      required this.toggleDrawer,
      required this.changeTab})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('MANAGE PROFILE',
            style: TextStyle(
              color: linkColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              fontSize: 18,
            )),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SizedBox(
                width: 24,
                child: IconButton(
                    onPressed: () {
                      toggleDrawer();
                    },
                    icon: const Icon(FontAwesomeIcons.bars,
                        size: 20, color: linkColor))),
          )
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: SingleChildScrollView(
            child: Column(children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ImagePreview(image: user.photoUrl!),
                                  ));
                            },
                            child: InkWell(
                              child: CircleAvatar(
                                backgroundColor: linkColor,
                                radius: 60,
                                child: CircleAvatar(
                                    radius: 58,
                                    backgroundColor: primaryColor,
                                    backgroundImage: Image.network(
                                        user.photoUrl!).image),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user.name,
                            style: const TextStyle(
                                color: linkColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            user.typeName,
                            style: const TextStyle(
                              color: linkColor,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                              height: 25,
                              width: 80,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: linkColor),
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    changeTab(1);
                                  },
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'CONTACTS',
                        style: TextStyle(
                            color: textColor.withOpacity(0.4),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomButton.customIconButton(context,
                        size: size,
                        height: small,
                        icon: FontAwesomeIcons.solidEnvelope,
                        label: 'Email',
                        text: user.email),
                    const SizedBox(height: 10),
                    CustomButton.customIconButton(context,
                        size: size,
                        height: small,
                        icon: FontAwesomeIcons.phone,
                        label: 'Phone',
                        text: user.phone),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'ADDRESS',
                        style: TextStyle(
                            color: textColor.withOpacity(0.4),
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ]),
              const SizedBox(height: 5),
              buildAdress(label: 'Street', value: user.street),
              buildAdress(label: 'Barangay', value: user.barangay),
              buildAdress(label: 'Municipality/City', value: user.city),
              buildAdress(label: 'Province', value: user.province),
              buildAdress(label: 'Zip Code', value: '${user.zipcode}'),
            ]),
          )),
    );
  }

  Widget buildAdress({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        width: double.infinity,
        height: small,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: '$label:',
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const WidgetSpan(
                  child: SizedBox(width: 8),
                ),
                TextSpan(
                    text: value,
                    style: TextStyle(
                        color: linkColor.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
