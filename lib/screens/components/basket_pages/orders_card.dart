import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/api/notification_api.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/order.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/chat_page/chat_box.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
                  trailing: buildTrailing()),
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
                  widget.user.userTypeId == 1
                      ? widget.order.status == 4
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
                          : buildStatusFarmer()
                      : buildStatusConsumer()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row buildStatusFarmer() {
    if (widget.order.status == 0) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                ShoWInfo.showUpDialog(context,
                    title: 'Accept Order',
                    message: 'Are you sure you want to accept this order?',
                    action1: 'Yes',
                    btn1: () {
                      ProductPost.updateOrderStatus(
                              order: widget.order,
                              orderStatus: 1,
                              userTypeId: user.userTypeId)
                          .whenComplete(() => ShoWInfo.showToast(
                              'Order has been accepted.', 3));
                      Navigator.of(context).pop();
                    },
                    action2: 'No',
                    btn2: () {
                      Navigator.of(context).pop();
                    });
              },
              child: Container(
                  height: 26,
                  width: 64,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), color: linkColor),
                  child: const Center(
                      child: Text('Accept',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                ShoWInfo.showUpDialog(context,
                    title: 'Accept Order',
                    message: 'Are you sure you want to deny this order?',
                    action1: 'Yes',
                    btn1: () {
                      ProductPost.updateOrderStatus(
                              order: widget.order,
                              orderStatus: 3,
                              userTypeId: user.userTypeId)
                          .whenComplete(() =>
                              ShoWInfo.showToast('Order has been denied.', 3));
                      Navigator.of(context).pop();
                    },
                    action2: 'No',
                    btn2: () {
                      Navigator.of(context).pop();
                    });
              },
              child: const SizedBox(
                  height: 26,
                  width: 55,
                  child: Center(
                      child: Text('Deny',
                          style: TextStyle(
                              color: linkColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)))),
            ),
          )
        ],
      );
    } else if (widget.order.status == 1) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                ProductPost.updateOrderStatus(
                        orderStatus: 2,
                        userTypeId: widget.user.userTypeId,
                        order: widget.order)
                    .whenComplete(
                        () => ShoWInfo.showToast('Order has been sold.', 3));
              },
              child: Container(
                  height: 26,
                  width: 64,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), color: linkColor),
                  child: const Center(
                      child: Text('Paid',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                ShoWInfo.showUpDialog(
                  context,
                  title: 'Delete Order',
                  message: 'Are you sure you want to delete this order?',
                  action1: 'Yes',
                  btn1: () {
                    ProductPost.deleteOrder(orderId: widget.order.orderId!)
                        .whenComplete(() =>
                            ShoWInfo.showToast('Order has been deleted.', 3));

                    Navigator.of(context).pop();
                  },
                  action2: 'No',
                  btn2: () {
                    Navigator.of(context).pop();
                  },
                );
              },
              child: const SizedBox(
                  height: 26,
                  width: 55,
                  child: Center(
                      child: Text('Delete',
                          style: TextStyle(
                              color: linkColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)))),
            ),
          )
        ],
      );
    } else {
      return Row();
    }
  }

  Widget buildStatusConsumer() {
    String msg = '';

    if (widget.order.status == 1) {
      msg = 'Order is ready for pick up';
    } else if (widget.order.status == 3) {
      msg = 'Your order was denied';
    } else {
      msg = 'Waiting for confirmation';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
          height: 26,
          width: 160,
          child: Center(
              child: Text(msg,
                  style: TextStyle(
                      color: widget.order.status == 3
                          ? Colors.red
                          : widget.order.status == 0
                              ? linkColor.withOpacity(0.7)
                              : linkColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)))),
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

  Widget buildTrailing() {
    if (widget.order.status == 3) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: GestureDetector(
            onTap: () {
              ProductPost.deleteOrder(orderId: widget.order.orderId!)
                  .whenComplete(
                      () => ShoWInfo.showToast('Order has been deleted.', 3));
            },
            child: const Icon(
              FontAwesomeIcons.xmark,
              color: linkColor,
              size: 18,
            )),
      );
    } else if (widget.order.status == 4) {
      return RatingBar.builder(
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
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatBox(
                        receiver: widget.user.userTypeId == 1
                            ? widget.order.costumer
                            : widget.order.publisher,
                        author: user,
                      )),
            );
          },
          child: RichText(
            text: TextSpan(
              children: [
                const WidgetSpan(
                    child: FaIcon(FontAwesomeIcons.solidComment,
                        size: 18, color: linkColor)),
                const WidgetSpan(
                  child: SizedBox(width: 5),
                ),
                TextSpan(
                    text: widget.user.userTypeId == 1
                        ? 'Contact Consumer'
                        : 'Contact Farmer',
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }
  }
}
