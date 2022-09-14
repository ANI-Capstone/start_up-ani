import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/feed.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../feed_page/feed_card.dart';

class UserFeeds extends StatefulWidget {
  UserFeeds({Key? key}) : super(key: key);

  @override
  State<UserFeeds> createState() => _UserFeedsState();
}

class _UserFeedsState extends State<UserFeeds> {
  User user = User(
      userId: '666666',
      name: 'Lucifer Morningstar',
      photoUrl: 'https://i.ibb.co/nsvsfcj/FUBBHt-KXw-AI4-WV5-2.jpg');
  final sample = Feed(
      author: User(
          userId: '666666',
          name: 'Lucifer Morningstar',
          photoUrl: 'https://i.ibb.co/nsvsfcj/FUBBHt-KXw-AI4-WV5-2.jpg'),
      caption:
          'Lorem ipsum dolor sit amet, consecteturdadawdawdadadadad... See more',
      upload:
          'https://i.ibb.co/Wz3VLCj/daikon-radish-1296x728-header-1296x728.webp',
      price: 'P1,500',
      date: 'September 1, 2022');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: const [
              Text(
                'FEED',
                style: TextStyle(color: linkColor, fontWeight: FontWeight.bold),
              )
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.magnifyingGlass,
                  size: 20, color: linkColor),
              onPressed: () {
                //wala pay design sa search na part
              },
            )
          ],
          backgroundColor: primaryColor,
          elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            FeedCard(feed: sample),
            FeedCard(feed: sample),
            FeedCard(feed: sample),
            FeedCard(feed: sample),
          ]),
        ),
      ),
    );
  }
}
