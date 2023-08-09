import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/models/orders.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/screens/components/basket_pages/to_rate.dart';
import 'package:ani_capstone/screens/components/feed_page/post_card.dart';
import 'package:ani_capstone/screens/components/widgets/pull_refresh.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

    fetchData();
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
                padding: const EdgeInsets.symmetric(
                    horizontal: (defaultPadding - 10)),
                child: SizedBox(
                    width: size.width,
                    height: 70,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: primaryColor,
                              backgroundImage: Image.network(
                                  widget.user.photoUrl!).image,
                            ),
                            const SizedBox(width: 20),
                            Text(
                              widget.user.name,
                              style: const TextStyle(
                                  color: linkColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            )
                          ]),
                          SizedBox(
                              width: 24,
                              child: IconButton(
                                  onPressed: () {
                                    widget.toggleDrawer();
                                  },
                                  icon: const Icon(FontAwesomeIcons.bars,
                                      size: 20, color: linkColor))),
                        ])),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: (defaultPadding - 10)),
                child: Text(
                  widget.user.userTypeId == 1 ? 'My Posts' : 'Complete Orders',
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
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: posts.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: PostCard(
                                        post: posts[index],
                                        user: widget.user,
                                        fetchData: () {
                                          fetchData();
                                        },
                                      ),
                                    );
                                  }),
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
}
