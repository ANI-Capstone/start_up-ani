import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/order.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/screens/components/user/user_post_review.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ToRate extends StatefulWidget {
  Order order;
  UserData user;
  ToRate({Key? key, required this.order, required this.user}) : super(key: key);

  @override
  _ToRateState createState() => _ToRateState();
}

class _ToRateState extends State<ToRate> {
  late UserData user;
  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      elevation: 1.5,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(widget.user.userTypeId == 1
                        ? widget.order.costumer.photoUrl
                        : widget.order.publisher.photoUrl)),
                title: Text(
                  widget.user.userTypeId == 1
                      ? widget.order.costumer.name
                      : widget.order.publisher.name,
                  style: const TextStyle(
                      color: linkColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold),
                ),
                trailing: widget.order.status == 4
                    ? RatingBar.builder(
                        initialRating: widget.order.rating!,
                        ignoreGestures: true,
                        direction: Axis.horizontal,
                        itemCount: 5,
                        unratedColor: primaryColor.withOpacity(0.7),
                        itemPadding: const EdgeInsets.symmetric(horizontal: 1),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemSize: 16,
                        onRatingUpdate: (rating) {
                          null;
                        },
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Row(
                children: [
                  buildLabel('Product', 0, width * 0.40),
                  buildLabel('Qty.', 1, width * 0.22),
                  buildLabel('Price', 2, width * 0.19),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.order.products.length,
                  itemBuilder: (context, index) {
                    return buildProduct(
                        context, widget.order.products[index], width, index);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                                text: 'Total Price: ',
                                style: TextStyle(
                                    color: linkColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: '\u20B1${widget.order.totalPrice}',
                                style: const TextStyle(
                                    color: linkColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () {
                        if (widget.order.status != 4) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserPostReview(
                                  user: user,
                                  order: widget.order,
                                ),
                              ));
                        }
                      },
                      child: widget.order.status == 4
                          ? Container(
                              height: 26,
                              width: 64,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: linkColor.withOpacity(0.7))),
                              child: const Center(
                                  child: Text('Rated',
                                      style: TextStyle(
                                          color: linkColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold))))
                          : Container(
                              height: 26,
                              width: 64,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: linkColor),
                              child: const Center(
                                  child: Text('Rate',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)))),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () {},
                      child: const SizedBox(
                          height: 26,
                          width: 55,
                          child: Center(
                              child: Text('Buy Again',
                                  style: TextStyle(
                                      color: linkColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)))),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLabel(String label, int index, double space) {
    return SizedBox(
      width: space,
      child: index == 0
          ? Text(
              label,
              style: const TextStyle(
                  fontSize: 12.5,
                  color: linkColor,
                  fontWeight: FontWeight.bold),
            )
          : Center(
              child: Text(
                label,
                style: const TextStyle(
                    fontSize: 12.5,
                    color: linkColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  Widget buildProduct(
      BuildContext context, Product product, double width, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            child: CachedNetworkImage(
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              imageUrl: product.post!.images[0],
              placeholder: (context, url) => Container(
                decoration: const BoxDecoration(color: primaryColor),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, size: 12, color: linkColor),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: (width * 0.40) - 53,
              child: Text(
                product.post!.name,
                style: const TextStyle(
                    color: linkColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: width * 0.21,
            child: Center(
              child: Container(
                width: 22,
                height: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: linkColor)),
                child: Center(
                  child: Text(
                    '${widget.order.products[index].quantity}',
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: width * 0.20,
            child: Center(
                child: Text('\u20B1${widget.order.products[index].tPrice!}',
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );
  }
}
