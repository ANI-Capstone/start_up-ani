import 'dart:async';

import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PostCard extends StatefulWidget {
  Post post;
  UserData user;
  PostCard({Key? key, required this.post, required this.user})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Timer _timer;
  late User user;
  String textButton = 'See more';
  bool liked = false;

  int duration = 0;

  late SharedPreferences prefs;
  Color? like = unLikeColor;
  late String description;

  final selectedColor = Colors.white;
  final unSelectedColor = const Color(0xFFB5B5B5);
  int selected = 0;

  @override
  void initState() {
    super.initState();

    user = User(
        name: widget.user.name,
        userId: widget.user.id,
        photoUrl: widget.user.photoUrl!);

    description = widget.post.description.length > 85
        ? '${widget.post.description.characters.take(85)}...'
        : widget.post.description;

    setLiked();
    _timer = Timer(Duration(seconds: duration), () {});
  }

  void setLiked() async {
    if (widget.post.likes!.isNotEmpty &&
        widget.post.likes!.contains(user.userId)) {
      if (mounted) {
        setState(() {
          liked = true;
          like = likeColor;
        });
      }
    }
  }

  void saveLike() async {
    _timer = Timer(Duration(seconds: duration), () async {
      setState(() {
        duration = 10;
        ProductPost.updateLike(
            user: user,
            publisher: widget.post.publisher,
            liked: liked,
            productId: widget.post.postId!);
      });
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
                    backgroundImage:
                        NetworkImage(widget.post.publisher.photoUrl)),
                title: Text(
                  widget.post.publisher.name,
                  style: const TextStyle(
                      color: linkColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  DateFormat('MMMM dd, yyyy').format(widget.post.postedAt),
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
                          text: widget.post.name,
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
                          visible: widget.post.description.length > 85
                              ? true
                              : false,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (textButton == 'See more') {
                                  description = widget.post.description;
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
                        items: widget.post.images
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
                                width: widget.post.images.length * 9,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: widget.post.images.length,
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
                            child: Text(
                                'P${widget.post.price}/${widget.post.unit}',
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
                              text: widget.post.location.length > 48
                                  ? '${widget.post.location.characters.take(48)}...'
                                  : widget.post.location,
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
                                  } else {
                                    like = likeColor;
                                    liked = true;
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
                                text: widget.post.likes!.length == 1
                                    ? '${widget.post.likes!.length} Like'
                                    : '${widget.post.likes!.length} Likes',
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
                          if (widget.post.publisher.userId != user.userId) {
                            ProductPost.addToBasket(
                                    userId: user.userId!, post: widget.post)
                                .whenComplete(() {
                              ShoWInfo.showToast('Added to basket.', 3);
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
