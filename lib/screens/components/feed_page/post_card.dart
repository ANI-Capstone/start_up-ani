import 'dart:async';

import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/api/firebase_message.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../chat_page/chat_box.dart';

class PostCard extends StatefulWidget {
  Post post;
  UserData user;
  PostCard({Key? key, required this.post, required this.user})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Post post;
  late UserData userData;
  late User publisher;
  late User user;

  late String description;
  late Color like;
  late int likes;
  late Timer _timer;
  late String productId;

  String textButton = 'See more';
  bool liked = false;

  int duration = 0;

  late SharedPreferences prefs;

  final selectedColor = Colors.white;
  final unSelectedColor = const Color(0xFFB5B5B5);
  int selected = 0;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    userData = widget.user;
    publisher = widget.post.publisher;
    description = widget.post.description.length > 85
        ? '${widget.post.description.characters.take(85)}...'
        : widget.post.description;
    likes = widget.post.likes!;
    like = unLikeColor;
    productId = post.postId!;

    user = User(
        name: widget.user.name,
        userId: widget.user.id,
        photoUrl: widget.user.photoUrl!);

    setLiked();
    _timer = Timer(Duration(seconds: duration), () {});
  }

  Future setLiked() async {
    prefs = await SharedPreferences.getInstance();

    final prefLike = prefs.getBool('${userData.id!} + $productId');

    if (prefLike != null) {
      setState(() {
        liked = prefLike;
        liked ? like = likeColor : unLikeColor;
      });
    } else {
      ProductPost.checkProductLike(userId: userData.id!, productId: productId)
          .then((value) {
        setState(() {
          liked = value;
          liked ? like = likeColor : unLikeColor;
        });
      });

      await prefs.setBool('${user.userId!} + $productId', liked);
    }
  }

  Future getQuantity({required String productId}) async {
    prefs = await SharedPreferences.getInstance();

    final prefQuantity = prefs.getInt('${user.userId!} + $productId - Q');

    if (prefQuantity != null) {
      await prefs.setInt('${user.userId!} + $productId - Q', prefQuantity + 1);
      return prefQuantity + 1;
    } else {
      await prefs.setInt('${user.userId!} + $productId - Q', 1);
      return 1;
    }
  }

  void saveLike() async {
    _timer = Timer(Duration(seconds: duration), () async {
      setState(() {
        duration = 10;
        ProductPost.updateLike(
            user: user,
            publisherId: publisher.userId!,
            liked: liked,
            productId: productId,
            likes: likes);
      });

      await prefs.setBool('${userData.id!} + $productId', liked);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Material(
        elevation: 1.5,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(publisher.photoUrl)),
                title: Text(
                  publisher.name,
                  style: const TextStyle(
                      color: linkColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat('MMMM dd, yyyy').format(post.postedAt),
                  style: const TextStyle(color: linkColor, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 15, bottom: 5),
                child: RichText(
                  text: TextSpan(
                    children: [
                      const WidgetSpan(
                        child: FaIcon(
                          FontAwesomeIcons.tags,
                          color: linkColor,
                          size: 16,
                        ),
                      ),
                      const WidgetSpan(
                        child: SizedBox(width: 5),
                      ),
                      TextSpan(
                          text: post.name,
                          style: const TextStyle(
                              color: linkColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: description,
                            style: const TextStyle(
                                color: linkColor, fontSize: 13)),
                        const WidgetSpan(
                          child: SizedBox(width: 5),
                        ),
                        WidgetSpan(
                            child: Visibility(
                          visible: post.description.length > 85 ? true : false,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (textButton == 'See more') {
                                  description = post.description;
                                  textButton = 'Close';
                                } else {
                                  description =
                                      '${description.characters.take(85)}...';
                                  textButton = 'See more';
                                }
                              });
                            },
                            child: Text(textButton,
                                style: const TextStyle(
                                    color: linkColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ))
                      ],
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5)),
                  child: Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                            enableInfiniteScroll: false,
                            viewportFraction: 1,
                            onScrolled: (value) {
                              if (value! % 1 == 0) {
                                setState(() {
                                  selected = value.toInt();
                                });
                              }
                            }),
                        items: post.images
                            .map((item) => Image.network(item,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150))
                            .toList(),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 40,
                                width: post.images.length * 9,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: post.images.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return InkWell(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 1.5),
                                          child: Container(
                                            height: 6,
                                            width: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: index == selected
                                                  ? selectedColor
                                                  : unSelectedColor,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 10,
                        child: Container(
                          width: 100,
                          height: 20,
                          decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(5)),
                          child: Center(
                            child: Text('P${post.price}/${post.unit}',
                                style: const TextStyle(
                                  color: linkColor,
                                  fontSize: 11,
                                )),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  width: double.infinity,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5)),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const WidgetSpan(
                            child: FaIcon(
                              FontAwesomeIcons.locationDot,
                              color: linkColor,
                              size: 14,
                            ),
                          ),
                          const WidgetSpan(
                            child: SizedBox(width: 5),
                          ),
                          TextSpan(
                              text: post.location.length > 48
                                  ? '${post.location.characters.take(48)}...'
                                  : post.location,
                              style: const TextStyle(
                                  color: linkColor,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(children: [
                    Positioned(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                                child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (liked) {
                                    like = unLikeColor;
                                    liked = false;
                                    likes -= 1;
                                  } else {
                                    like = likeColor;
                                    liked = true;
                                    likes += 1;
                                  }
                                });

                                if (!_timer.isActive) saveLike();
                              },
                              child: FaIcon(FontAwesomeIcons.solidThumbsUp,
                                  size: 18, color: like),
                            )),
                            const WidgetSpan(
                              child: SizedBox(width: 5),
                            ),
                            TextSpan(
                                text:
                                    likes == 1 ? '$likes Like' : '$likes Likes',
                                style: TextStyle(color: like, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 75,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            WidgetSpan(
                                child: GestureDetector(
                              child: const FaIcon(
                                  FontAwesomeIcons.solidComments,
                                  size: 18,
                                  color: linkColor),
                            )),
                            const WidgetSpan(
                              child: SizedBox(width: 5),
                            ),
                            const TextSpan(
                                text: '0 Reviews',
                                style:
                                    TextStyle(color: linkColor, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 34,
                      child: GestureDetector(
                        onTap: () {
                          if (publisher.userId != user.userId) {
                            ProductPost.addToBasket(
                                    userId: user.userId!, post: post)
                                .whenComplete(() {
                              ShoWInfo.showToast(
                                  context, 'Added to basket.', 3);
                            });
                          }
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                  child: FaIcon(FontAwesomeIcons.bagShopping,
                                      size: 18,
                                      color: widget.user.userTypeId != 1
                                          ? linkColor
                                          : unLikeColor)),
                              const WidgetSpan(
                                child: SizedBox(width: 5),
                              ),
                              TextSpan(
                                  text: 'Add to basket',
                                  style: TextStyle(
                                      color: widget.user.userTypeId != 1
                                          ? linkColor
                                          : unLikeColor,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    )
                  ]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
