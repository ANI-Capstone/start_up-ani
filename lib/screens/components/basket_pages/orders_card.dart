import 'package:ani_capstone/api/firebase_firestore.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/order.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/chat_page/chat_box.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrdersCard extends StatefulWidget {
  Order order;
  UserData user;
  OrdersCard({Key? key, required this.order, required this.user})
      : super(key: key);

  @override
  _OrdersCardState createState() => _OrdersCardState();
}

class _OrdersCardState extends State<OrdersCard> {
  late Order order;
  late User publisher;
  late UserData user;

  late List<Product> products;

  @override
  void initState() {
    super.initState();

    order = widget.order;
    publisher = widget.order.publisher;
    products = widget.order.products;
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
                    backgroundImage: NetworkImage(publisher.photoUrl)),
                title: Text(
                  publisher.name,
                  style: const TextStyle(
                      color: linkColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatBox(
                                  receiver: publisher,
                                  author: user,
                                )),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          WidgetSpan(
                              child: FaIcon(FontAwesomeIcons.solidComment,
                                  size: 18, color: linkColor)),
                          WidgetSpan(
                            child: SizedBox(width: 5),
                          ),
                          TextSpan(
                              text: 'Contact Farmer',
                              style: TextStyle(
                                  color: linkColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
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
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return buildProduct(context, products[index], width, index);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                                text: '\u20B1${order.totalPrice}',
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
                    child: SizedBox(
                        height: 26,
                        width: 160,
                        child: Center(
                            child: Text(buildStatus(),
                                style: TextStyle(
                                    color: widget.order.status == 2
                                        ? Colors.red
                                        : widget.order.status == 0
                                            ? linkColor.withOpacity(0.7)
                                            : linkColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)))),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String buildStatus() {
    if (widget.order.status == 1) {
      return 'Order is ready for pick up';
    } else if (widget.order.status == 2) {
      return 'Your order was denied';
    } else {
      return 'Waiting for confirmation';
    }
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
                    '${products[index].quantity}',
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
                child: Text('\u20B1${products[index].tPrice!}',
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
