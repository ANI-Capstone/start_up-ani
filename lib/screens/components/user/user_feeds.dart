import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/screens/components/feed_page/post_card.dart';
import 'package:ani_capstone/screens/components/user/user_basket.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants.dart';

class UserFeed extends StatefulWidget {
  UserData user;
  Function(bool open) openBasket;

  int badgeCount;
  UserFeed(
      {required this.user,
      required this.openBasket,
      required this.badgeCount,
      super.key});

  @override
  State<UserFeed> createState() => _UserFeedState();
}

class _UserFeedState extends State<UserFeed> {
  UserData? user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('FEED',
                      style: TextStyle(
                          color: linkColor, fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: GestureDetector(
                        onTap: () {
                          widget.openBasket(true);
                        },
                        child: Badge(
                          // badgeColor: badgeColor,
                          badgeContent: Text(
                            '${widget.badgeCount}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                          showBadge: widget.badgeCount > 0,
                          elevation: 3,
                          position: BadgePosition.topEnd(top: -13, end: -11),
                          child: const Icon(FontAwesomeIcons.bagShopping,
                              size: 22, color: linkColor),
                        )),
                  )
                ]),
            backgroundColor: primaryColor,
            elevation: 0),
        backgroundColor: userBgColor,
        body: StreamBuilder<List<Post>>(
            stream: ProductPost.getPosts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong.'));
              } else if (snapshot.hasData) {
                final posts = snapshot.data!;

                return posts.isEmpty
                    ? const Center(child: Text('No posts.'))
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListView(
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            children: posts.map(buildPost).toList()),
                      );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }

  Widget buildPost(Post post) => PostCard(
        post: post,
        user: user!,
      );
}
