import 'dart:async';

import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/feed_page/edit_post.dart';
import 'package:ani_capstone/screens/components/review_page/review_screen.dart';
import 'package:ani_capstone/screens/components/widgets/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PostCard extends StatefulWidget {
  Post post;
  UserData user;
  VoidCallback? fetchData;
  PostCard({Key? key, required this.post, required this.user, this.fetchData})
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

  final selectedColor = Colors.white;
  final unSelectedColor = const Color(0xFFB5B5B5);
  int selected = 0;

  final _formKey = GlobalKey<FormState>();
  final _newPrice = TextEditingController();

  @override
  void initState() {
    super.initState();

    user = User(
        name: widget.user.name,
        userId: widget.user.id,
        photoUrl: widget.user.photoUrl!);

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

  void deletePost() {
    ProductPost.deletePost(post: widget.post).whenComplete(() {
      ShoWInfo.showToast('Your post has been deleted successfully.', 3);
      Navigator.of(context).pop();
      widget.fetchData!();
    }).onError((error, stackTrace) {
      ShoWInfo.showToast('Failed to delete post.', 3);
      Navigator.of(context).pop();
    });
  }

  void onPopupButtonClick(value) {
    switch (value) {
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPost(
                post: widget.post,
                fetchData: () {
                  widget.fetchData!();
                },
              ),
            ));
        break;
      case 2:
        showDialog(
            context: context,
            builder: (context) {
              return _updatePriceDialog(context);
            });
        break;
      case 3:
        ShoWInfo.showUpDialog(context,
            title: 'Delete Post',
            message:
                'Are you sure you want to delete this post? This action is cannot be undone.',
            action1: 'Yes',
            btn1: () {
              deletePost();
            },
            action2: 'Cancel',
            btn2: () {
              Navigator.of(context).pop();
            });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
                  leading: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImagePreview(
                                  image: widget.post.publisher.photoUrl),
                            ));
                      },
                      child: CircleAvatar(
                          backgroundColor: primaryColor,
                          radius: 22,
                          backgroundImage: Image.network(
                              widget.post.publisher.photoUrl
                             ).image)),
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
                  trailing: widget.fetchData != null &&
                          widget.user.id == widget.post.publisher.userId
                      ? SizedBox(
                          width: 20,
                          height: 80,
                          child: PopupMenuButton(
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              onSelected: (value) {
                                onPopupButtonClick(value);
                              },
                              padding: const EdgeInsets.all(0),
                              position: PopupMenuPosition.under,
                              itemBuilder: (context) => [
                                    buildPopupItems(
                                        icon: FontAwesomeIcons.pencil,
                                        label: "Edit",
                                        value: 1),
                                    buildPopupItems(
                                        icon: FontAwesomeIcons.pesoSign,
                                        label: "Edit Price",
                                        value: 2),
                                    buildPopupItems(
                                        icon: FontAwesomeIcons.trashCan,
                                        label: "Delete",
                                        value: 3),
                                  ],
                              icon: const Icon(
                                FontAwesomeIcons.ellipsisVertical,
                                color: linkColor,
                                size: 20,
                              )),
                        )
                      : null),
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
                            text: textButton == 'See more' &&
                                    widget.post.description.length > 85
                                ? '${widget.post.description.characters.take(85)}...'
                                : widget.post.description,
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
                                  textButton = 'Close';
                                } else {
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
                            .map((item) => GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ImagePreview(image: item),
                                        ));
                                  },
                                  child: Image(
                                      image: Image.network(item).image,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 150),
                                ))
                            .toList(),
                      ),
                      if (widget.post.images.length > 1)
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
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                  child: FaIcon(FontAwesomeIcons.solidThumbsUp,
                                      size: 18, color: like)),
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
                    ),
                    Positioned(
                      left: 75,
                      child: GestureDetector(
                        onTap: () {
                          if (widget.post.reviews!.isNotEmpty) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewScreen(
                                    productId: widget.post.postId!,
                                  ),
                                ));
                          } else {
                            ShoWInfo.showToast(
                                'This product has no reviews.', 0);
                          }
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const WidgetSpan(
                                  child: FaIcon(FontAwesomeIcons.solidComments,
                                      size: 18, color: linkColor)),
                              const WidgetSpan(
                                child: SizedBox(width: 5),
                              ),
                              TextSpan(
                                  text: widget.post.reviews!.length == 1
                                      ? '${widget.post.reviews!.length} Review'
                                      : '${widget.post.reviews!.length} Reviews',
                                  style: const TextStyle(
                                      color: linkColor, fontSize: 12)),
                            ],
                          ),
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

  PopupMenuItem buildPopupItems(
      {required IconData icon, required String label, required int value}) {
    return PopupMenuItem(
      value: value,
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: FaIcon(
                icon,
                color: linkColor,
                size: 20,
              ),
            ),
            const WidgetSpan(
              child: SizedBox(width: 8),
            ),
            TextSpan(
                text: label,
                style: const TextStyle(
                    color: linkColor,
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _updatePriceDialog(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Update Product Price',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _newPrice,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: widget.post.price.toString(),
                prefixIcon: const Icon(FontAwesomeIcons.pesoSign, size: 18),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please input a price';
                }

                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              FocusManager.instance.primaryFocus?.unfocus();
              ShoWInfo.showUpDialog(context,
                  title: "Confirmation",
                  message:
                      'Are you sure you want to update the price of this product?',
                  action1: 'Yes',
                  btn1: () {
                    ProductPost.updatePrice(
                            postId: widget.post.postId!,
                            newPrice: double.parse(_newPrice.text.trim()))
                        .whenComplete(() {
                      ShoWInfo.showToast('Price updated successfully.', 3);
                      Navigator.of(context).pop();
                    }).onError((error, stackTrace) {
                      ShoWInfo.showToast('Price updated failed.', 3);
                      Navigator.of(context).pop();
                    });
                  },
                  action2: 'Cancel',
                  btn2: () {
                    Navigator.of(context).pop();
                  }).whenComplete(() => Navigator.of(context).pop());
            }
          },
          child: const Text('Save',
              style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel',
              style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
        ),
      ],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
    );
  }
}
