import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/models/message.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/chat_page/chat_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants.dart';

class UserInbox extends StatefulWidget {
  UserInbox({Key? key}) : super(key: key);

  @override
  State<UserInbox> createState() => _UserInboxState();
}

class _UserInboxState extends State<UserInbox> {
  User user = User(
      userId: '12121',
      name: 'Mark Zuckmyberd',
      photoUrl: 'https://i.ibb.co/StGZh5F/20180411134321-zuck.webp');
  final sample = Message(
      author: User(
          userId: '12121',
          name: 'Mark Zuckmyberd',
          photoUrl: 'https://i.ibb.co/StGZh5F/20180411134321-zuck.webp'),
      message: 'dawdLorem ipsum dolor sit amet, consecteturdadawdawdadadadad',
      timeStamp: '8 min');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('INBOX',
                  style:
                      TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
              Icon(FontAwesomeIcons.magnifyingGlass, size: 20, color: linkColor)
            ],
          ),
          backgroundColor: primaryColor,
          elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.only(top: 15),
                child: StreamBuilder<List<User>>(
                    stream: FirebaseMessageApi.getUsers(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong.');
                      } else if (snapshot.hasData) {
                        final users = snapshot.data!;
                        return SizedBox(
                          height: 90,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: users.map(buildUser).toList()),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                child: SizedBox(
                  child: Text(
                    'Messages',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),
              ChatCard(message: sample),
              ChatCard(message: sample),
              ChatCard(message: sample)
            ]),
          ),
        ),
      ),
    );
  }

  Widget buildUser(User user) => Container(
      margin: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {},
        child: SizedBox(
          width: 70,
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              const SizedBox(height: 5),
              Text(
                user.name,
                style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: linkColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ));
}
