import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/review.dart';
import 'package:ani_capstone/screens/components/review_page/review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReviewScreen extends StatefulWidget {
  String productId;
  ReviewScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<Review> reviews = [];

  int fetchState = 0;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  void fetchReviews() {
    ProductPost.getProductReviews(productId: widget.productId).then((reviews) {
      if (reviews.isNotEmpty) {
        this.reviews = reviews;
        if (mounted) {
          setState(() {
            fetchState = 1;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(FontAwesomeIcons.arrowLeft,
                  color: linkColor, size: 18)),
          title: const Text('PRODUCT REVIEWS',
              style: TextStyle(
                color: linkColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              )),
          backgroundColor: primaryColor,
          elevation: 0),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Column(
            mainAxisAlignment: fetchState != 1
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              fetchState == 1
                  ? SizedBox(
                      height: size.height - 120,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: ReviewCard(
                                review: reviews[index],
                              ),
                            );
                          }),
                    )
                  : statusBuilder()
            ]),
      ),
    );
  }

  Widget statusBuilder() {
    if (fetchState == 2) {
      return const Center(child: Text('Basket is empty.'));
    } else if (fetchState == -1) {
      return const Center(child: Text('An error occured, please try again.'));
    } else {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
