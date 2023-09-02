import 'dart:async';
import 'dart:math';

import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/models/post.dart';
import 'package:ani_capstone/screens/components/feed_page/post_card.dart';
import 'package:ani_capstone/screens/components/widgets/pull_refresh.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants.dart';

class UserFeed extends StatefulWidget {
  final UserData user;
  final Function(bool open) openBasket;

  final int badgeCount;
  final List<Product> addedProducts;

  const UserFeed(
      {required this.user,
      required this.openBasket,
      required this.badgeCount,
      required this.addedProducts,
      super.key});

  @override
  State<UserFeed> createState() => _UserFeedState();
}

class _UserFeedState extends State<UserFeed> {
  late UserData user;
  late StreamSubscription listener;

  int fetchState = 0;
  int searchState = 0;

  List<Post> posts = [];
  List<Post> searched = [];
  List<Product> addedProduct = [];

  final TextEditingController _searchInput = TextEditingController();
  bool isSearching = false;

  bool filterProduct = false;
  bool filterName = false;
  bool filterPlace = false;

  @override
  void initState() {
    super.initState();
    user = widget.user;

    loadPosts();
    feedListener();
  }

  @override
  void dispose() {
    super.dispose();
    listener.cancel();
  }

  void feedListener() async {
    final postRef = ProductPost.postStream();

    listener = postRef.listen((event) async {
      loadPosts();
    });
  }

  Future loadPosts() async {
    ProductPost.getPosts().then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            posts = value;
            fetchState = 1;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            fetchState = 2;
          });
        }
      }
    }).onError((error, stackTrace) {
      if (mounted) {
        setState(() {
          fetchState = -1;
        });
      }
    });
  }

  void searchProducts(String query) async {
    List<Post> suggestions = [];

    setState(() {
      searchState = 0;
    });

    if (filterName) {
      final suggestion = posts.where((post) {
        final farmerName = post.publisher.name.toLowerCase();
        final input = query.toLowerCase();

        return farmerName.contains(input);
      }).toList();

      suggestions.addAll(suggestion);
    }

    if (filterProduct) {
      final suggestion = posts.where((post) {
        final productName = post.name.toLowerCase();
        final input = query.toLowerCase();

        return productName.contains(input);
      }).toList();

      suggestions.addAll(suggestion);
    }

    if (filterPlace) {
      final suggestion = posts.where((post) {
        final place = post.location.toLowerCase();
        final input = query.toLowerCase();

        return place.contains(input);
      }).toList();

      suggestions.addAll(suggestion);
    }

    if (!filterName && !filterPlace && !filterProduct) {
      final suggestion = posts.where((post) {
        final farmerName = post.publisher.name.toLowerCase();
        final productName = post.name.toLowerCase();
        final place = post.location.toLowerCase();

        final input = query.toLowerCase();

        return farmerName.contains(input) ||
            productName.contains(input) ||
            place.contains(input);
      }).toList();

      suggestions.addAll(suggestion);
    }

    searched = suggestions;

    if (suggestions.isNotEmpty) {
      setState(() {
        searchState = 1;
      });
    } else {
      setState(() {
        searchState = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('FEED',
                style:
                    TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: GestureDetector(
                  onTap: () {
                    widget.openBasket(true);
                  },
                  child: badges.Badge(
                    badgeContent: Text(
                      '${widget.badgeCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    showBadge: widget.badgeCount > 0,
                    position: badges.BadgePosition.topEnd(top: -13, end: -11),
                    child: user.userTypeId == 1
                        ? const Icon(FontAwesomeIcons.store,
                            size: 22, color: linkColor)
                        : const Icon(FontAwesomeIcons.bagShopping,
                            size: 22, color: linkColor),
                  )),
            )
          ]),
          backgroundColor: primaryColor,
          elevation: 0),
      backgroundColor: userBgColor,
      body: fetchState != 1
          ? statusBuilder()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    searchBar(),
                    isSearching
                        ? searchState != 1
                            ? searchStatusBuilder()
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: searched.length,
                                itemBuilder: (context, index) =>
                                    buildPost(searched[index]))
                        : SizedBox(
                            height: size.height - 200,
                            child: RefreshWidget(
                              onRefresh: loadPosts,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: posts.length,
                                  itemBuilder: (context, index) =>
                                      buildPost(posts[index])),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                autofocus: false,
                controller: _searchInput,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    hintText: "Search a product",
                    isCollapsed: true,
                    isDense: true,
                    prefixIcon: const Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: primaryColor,
                    ),
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: primaryColor),
                    suffixIconConstraints:
                        BoxConstraints.tight(const Size(35, 18)),
                    prefixIconConstraints:
                        BoxConstraints.tight(const Size(45, 18)),
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                    suffixIcon: !isSearching
                        ? null
                        : GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(() {
                                _searchInput.clear();
                                isSearching = false;
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: primaryColor,
                            ))),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    searchProducts(value);
                    setState(() {
                      isSearching = true;
                    });
                  } else {
                    setState(() {
                      isSearching = false;
                    });
                  }
                },
                onTap: () {},
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: primaryColor, borderRadius: BorderRadius.circular(10)),
            child: PopupMenuButton(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                onSelected: (value) {
                  if (value == 1) {
                    setState(() {
                      filterName = !filterName;
                    });
                  } else if (value == 2) {
                    setState(() {
                      filterPlace = !filterPlace;
                    });
                  } else {
                    setState(() {
                      filterProduct = !filterProduct;
                    });
                  }
                },
                padding: const EdgeInsets.all(0),
                position: PopupMenuPosition.under,
                itemBuilder: (context) => [
                      buildPopupItems(
                          filter: filterProduct, label: "By Product", value: 0),
                      buildPopupItems(
                          filter: filterName, label: "By Farmer", value: 1),
                      buildPopupItems(
                          filter: filterPlace, label: "By Place", value: 2),
                    ],
                icon: Transform.rotate(
                  angle: 90 * pi / 180,
                  child: GestureDetector(
                    child: const Icon(
                      Icons.tune_rounded,
                      color: linkColor,
                      size: 26,
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }

  PopupMenuItem buildPopupItems(
      {required bool filter, required String label, required int value}) {
    return PopupMenuItem(
      value: value,
      padding: const EdgeInsets.all(8),
      height: 10,
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
                child: SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: filter,
                checkColor: Colors.white,
                activeColor: linkColor,
                onChanged: (val) {},
                side: BorderSide(width: 1, color: textColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
            )),
            const WidgetSpan(
              child: SizedBox(width: 8),
            ),
            WidgetSpan(
                child: Text(label,
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget statusBuilder() {
    if (fetchState == 2) {
      return SizedBox(
          height: (MediaQuery.of(context).size.height) * 0.6,
          child: const Center(child: Text('No posts')));
    } else if (fetchState == -1) {
      return SizedBox(
          height: (MediaQuery.of(context).size.height) * 0.6,
          child: const Center(
              child: Text('An error occurred, please restart the app.')));
    } else {
      return SizedBox(
          height: (MediaQuery.of(context).size.height) * 0.6,
          child: const Center(child: CircularProgressIndicator()));
    }
  }

  Widget searchStatusBuilder() {
    if (searchState == 2) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: Text('No search results')),
      );
    } else if (searchState == -1) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: Text('Aw, snap! An error occurred')),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: RichText(
          text: const TextSpan(
            children: [
              WidgetSpan(
                  child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryColor,
                ),
              )),
              WidgetSpan(
                child: SizedBox(width: 8),
              ),
              WidgetSpan(
                  child: Text('Searching...',
                      style: TextStyle(
                        color: linkColor,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ))),
            ],
          ),
        ),
      );
    }
  }

  Widget buildPost(Post post) => PostCard(
        post: post,
        user: user,
        addedProduct: widget.addedProducts,
      );
}
