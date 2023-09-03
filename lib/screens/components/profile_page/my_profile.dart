import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/models/orders.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/screens/components/basket_pages/to_rate.dart';
import 'package:ani_capstone/screens/components/widgets/image_handler.dart';
import 'package:ani_capstone/screens/components/widgets/pull_refresh.dart';
import 'package:ani_capstone/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/image_preview.dart';

class MyProfile extends StatefulWidget {
  UserData user;
  VoidCallback toggleDrawer;
  MyProfile({Key? key, required this.user, required this.toggleDrawer})
      : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  int fetchState = 0;

  List<Orders> orders = [];
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();

    // fetchData();
  }

  Future fetchData() async {
    final userType = widget.user.userTypeId;

    try {
      if (userType == 1) {
        ProductPost.getUserPosts(userId: widget.user.id!).then((value) {
          posts = value;

          if (value.isNotEmpty) {
            setState(() {
              fetchState = 1;
            });
          } else {
            setState(() {
              fetchState = 2;
            });
          }
        }).onError((error, stackTrace) {
          setState(() {
            fetchState = -1;
          });
        });
      } else {
        ProductPost.getUserOrders(userId: widget.user.id!).then((value) {
          orders = value;

          if (value.isNotEmpty) {
            setState(() {
              fetchState = 1;
            });
          } else {
            setState(() {
              fetchState = 2;
            });
          }
        }).onError((error, stackTrace) {
          setState(() {
            fetchState = -1;
          });
        });
      }
    } on Exception catch (_) {
      null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double itemHeight = 210;
    final double itemWidth = size.width / 2;

    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Center(
            child: Text('MY PROFILE',
                style: TextStyle(
                  color: linkColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                )),
          ),
          backgroundColor: primaryColor,
          elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: (defaultPadding - 20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    leading: SizedBox(
                      height: double.infinity,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImagePreview(
                                      image: widget.user.photoUrl!),
                                ));
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: primaryColor,
                            backgroundImage:
                                Image.network(widget.user.photoUrl!).image,
                          )),
                    ),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                              color: linkColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        if (widget.user.userTypeId == 1 && fetchState == 1)
                          RatingBar.builder(
                            initialRating: Utils.computeRating(posts),
                            allowHalfRating: true,
                            ignoreGestures: true,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            unratedColor: primaryColor.withOpacity(0.7),
                            itemPadding:
                                const EdgeInsets.symmetric(vertical: 2),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemSize: 16,
                            onRatingUpdate: (rating) {
                              null;
                            },
                          )
                      ],
                    ),
                    trailing: SizedBox(
                        width: 24,
                        child: IconButton(
                            onPressed: () {
                              widget.toggleDrawer();
                            },
                            icon: const Icon(FontAwesomeIcons.bars,
                                size: 20, color: linkColor)))),
              ),
              const SizedBox(height: 10),
              widget.user.userTypeId == 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: (defaultPadding - 10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Posts',
                            style: TextStyle(
                                color: textColor.withOpacity(0.3),
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Edit Products',
                              style: TextStyle(
                                color: linkColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: (defaultPadding - 10)),
                      child: Text(
                        'Complete Orders',
                        style: TextStyle(
                            color: textColor.withOpacity(0.3),
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
              const SizedBox(height: 10),
              fetchState == 1
                  ? widget.user.userTypeId == 1
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            height: size.height * 0.65,
                            width: double.infinity,
                            child: RefreshWidget(
                              onRefresh: fetchData,
                              child: GridView.count(
                                primary: false,
                                padding: const EdgeInsets.all(10),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                crossAxisCount: 2,
                                childAspectRatio: (itemWidth / itemHeight),
                                children: posts
                                    .map((post) => buildProduct(post))
                                    .toList(),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            height: size.height * 0.65,
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: orders.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: ToRate(
                                        order: orders[index],
                                        user: widget.user),
                                  );
                                }),
                          ),
                        )
                  : statusBuilder()
              // fetchState == 1
              //     ? widget.user.userTypeId == 1
              //         ? Padding(
              //             padding: const EdgeInsets.symmetric(horizontal: 10),
              //             child: SizedBox(
              //               height: size.height * 0.65,
              //               width: double.infinity,
              //               child: RefreshWidget(
              //                 onRefresh: fetchData,
              //                 child: ListView.builder(
              //                     scrollDirection: Axis.vertical,
              //                     physics: const BouncingScrollPhysics(),
              //                     shrinkWrap: true,
              //                     itemCount: posts.length,
              //                     itemBuilder: (context, index) {
              //                       return Padding(
              //                         padding: const EdgeInsets.symmetric(
              //                             vertical: 5),
              //                         child: PostCard(
              //                           post: posts[index],
              //                           user: widget.user,
              //                           fetchData: () {
              //                             fetchData();
              //                           },
              //                         ),
              //                       );
              //                     }),
              //               ),
              //             ),
              //           )
              //         : Padding(
              //             padding: const EdgeInsets.symmetric(horizontal: 10),
              //             child: SizedBox(
              //               height: size.height * 0.65,
              //               child: ListView.builder(
              //                   scrollDirection: Axis.vertical,
              //                   physics: const BouncingScrollPhysics(),
              //                   shrinkWrap: true,
              //                   itemCount: orders.length,
              //                   itemBuilder: (context, index) {
              //                     return Padding(
              //                       padding:
              //                           const EdgeInsets.symmetric(vertical: 5),
              //                       child: ToRate(
              //                           order: orders[index],
              //                           user: widget.user),
              //                     );
              //                   }),
              //             ),
              //           )
              //     : statusBuilder()
            ],
          ),
        ),
      ),
    );
  }

  Widget statusBuilder() {
    if (fetchState == 2) {
      return Center(
          child: Text(
              'No ${widget.user.userTypeId == 1 ? 'Posts' : 'Complete Orders'}'));
    } else if (fetchState == -1) {
      return const Center(child: Text('An error occurred, please try again.'));
    } else {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }

  Widget buildProduct(Post post) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                child: SizedBox(
                  height: 120,
                  child: ImageHandler(
                    image: post.images[0],
                    imageType: ImageHandler.postImage,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
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
                    const SizedBox(height: 5),
                    Text(
                      'P${post.price} / Kilogram',
                      style: const TextStyle(fontSize: 13, color: linkColor),
                    )
                  ],
                ),
              )
            ]),
      ),
    );
  }
}
