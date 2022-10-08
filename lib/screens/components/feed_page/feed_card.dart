import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/feed.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedCard extends StatelessWidget {
  Feed feed;

  FeedCard({Key? key, required this.feed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            height: 350,
            color: Colors.transparent,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(feed.author.photoUrl),
                    ),
                    title: Text(
                      (feed.author.name.length < 20)
                          ? feed.author.name
                          : '${feed.author.name.toString().characters.take(20)}...',
                      style: const TextStyle(
                          fontFamily: 'Roboto',
                          color: linkColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      feed.date,
                      style: const TextStyle(
                          fontFamily: 'Roboto', color: linkColor, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          ListTile(
                            subtitle: Text(
                              feed.caption,
                              style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  color: linkColor,
                                  fontSize: 14),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    image: DecorationImage(
                                        image: NetworkImage(feed.upload),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  bottom: 7,
                                  right: 7,
                                  child: Container(
                                    height: 15,
                                    width: 41,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        feed.price,
                                        style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 9,
                                            color: linkColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(children: [
                              Row(
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 2),
                                    child: FaIcon(
                                        FontAwesomeIcons.solidThumbsUp,
                                        color: linkColor),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Likes',
                                    style: TextStyle(
                                        fontFamily: 'Roboto',
                                        color: linkColor,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Icon(Icons.reviews_rounded,
                                          color: linkColor),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Reviews',
                                      style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: linkColor,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 13),
                                      child: FaIcon(
                                          FontAwesomeIcons.handHolding,
                                          color: linkColor),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Pick',
                                      style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: linkColor,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(40, 0, 0, 3),
                                child: Text(
                                  '5.0',
                                  style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize: 8,
                                      color: linkColor),
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 0, 5),
                                  child: Container()),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
