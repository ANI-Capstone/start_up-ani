import 'dart:async';

import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BasketCard extends StatefulWidget {
  User user;
  List<Product> products;
  int basketIndex;
  Function<Future>(
      {required String userId,
      required List<String> postId,
      required int basketIndex}) removeProduct;

  BasketCard(
      {Key? key,
      required this.user,
      required this.products,
      required this.removeProduct,
      required this.basketIndex})
      : super(key: key);

  @override
  _BasketCardState createState() => _BasketCardState();
}

class _BasketCardState extends State<BasketCard> {
  bool checkAll = false;
  Timer? timer;

  int totalPrice = 0;

  @override
  void initState() {
    super.initState();
  }

  void updateTotalPrice() {
    if (mounted) {
      setState(() {
        int sum = 0;
        for (int i = 0; i < widget.products.length; i++) {
          widget.products[i].tPrice = widget.products[i].post!.price.round() *
              widget.products[i].quantity;
          if (widget.products[i].checkBox!) {
            sum += widget.products[i].tPrice!;
          }
        }
        totalPrice = sum;
      });
    }
  }

  Future checkout() {
    List<Product> checkoutProducts = [];
    final User publisher = widget.products[0].publisher;

    for (int i = 0; i < widget.products.length; i++) {
      if (widget.products[i].checkBox!) {
        checkoutProducts.add(widget.products[i]);
      }
    }

    if (mounted) {
      setState(() {
        widget.removeProduct(
            userId: widget.user.userId!,
            postId:
                checkoutProducts.map((product) => product.productId).toList(),
            basketIndex: widget.basketIndex);
      });
    }

    return ProductPost.checkOutOrder(
      costumer: widget.user,
      publisher: publisher,
      products: checkoutProducts,
      totalPrice: totalPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      elevation: 1.5,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryColor,
                    backgroundImage: Image.network(
                            widget.products[0].post!.publisher.photoUrl)
                        .image),
                title: Text(
                  widget.products[0].post!.publisher.name,
                  style: const TextStyle(
                      color: linkColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Checkbox(
                    value: checkAll,
                    checkColor: Colors.white,
                    activeColor: linkColor,
                    onChanged: (value) {
                      setState(() {
                        checkAll = !checkAll;

                        for (int i = 0; i < widget.products.length; i++) {
                          widget.products[i].checkBox = checkAll;
                        }

                        updateTotalPrice();
                      });
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: const BorderSide(width: 1, color: linkColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                buildLabel('Product', 0, width * 0.34),
                buildLabel('Qty.', 1, width * 0.18),
                buildLabel('Price', 2, width * 0.19),
                buildLabel('Del.', 3, width * 0.08),
              ],
            ),
            ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  return buildProduct(
                      context, widget.products[index], width, index);
                }),
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
                                text: '\u20B1$totalPrice',
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
                        if (totalPrice > 0) {
                          checkout().whenComplete(() => ShoWInfo.showToast(
                              'Order checkout successfully.', 3));
                        }
                      },
                      child: Container(
                          height: 26,
                          width: 64,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: totalPrice > 0 ? linkColor : primaryColor),
                          child: const Center(
                              child: Text('Checkout',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)))),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(
                        height: 26,
                        width: 55,
                        child: Center(
                            child: Text('Delete',
                                style: TextStyle(
                                    color: linkColor,
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
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Checkbox(
            value: product.checkBox,
            checkColor: Colors.white,
            activeColor: linkColor,
            onChanged: (value) {
              setState(() {
                widget.products[index].checkBox =
                    !widget.products[index].checkBox!;
                if (checkAll) checkAll = false;

                updateTotalPrice();
              });
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: const BorderSide(width: 1, color: linkColor),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          child: Image.network(
            product.post!.images[0],
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, url, error) =>
                const Icon(Icons.error, size: 12, color: linkColor),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            width: (width * 0.34) - 48,
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
          width: width * 0.18,
          child: Row(children: [
            GestureDetector(
                onTapDown: (TapDownDetails details) {
                  if (widget.products[index].quantity > 1) {
                    timer =
                        Timer.periodic(const Duration(milliseconds: 200), (t) {
                      setState(() {
                        if (widget.products[index].quantity > 1) {
                          widget.products[index].quantity -= 1;
                          updateTotalPrice();
                        } else {
                          timer!.cancel();
                        }
                      });
                    });
                  }
                },
                onTap: () {
                  if (widget.products[index].quantity > 1) {
                    if (mounted) {
                      setState(() {
                        widget.products[index].quantity -= 1;
                        updateTotalPrice();
                      });
                    }
                  }
                },
                onTapUp: (TapUpDetails details) {
                  if (widget.products[index].quantity > 1) {
                    timer!.cancel();
                  }
                },
                onTapCancel: () {
                  timer!.cancel();
                },
                child: Icon(FontAwesomeIcons.minus,
                    size: 16,
                    color: widget.products[index].quantity <= 1
                        ? linkColor.withOpacity(0.5)
                        : linkColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: 22,
                height: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: linkColor)),
                child: Center(
                  child: Text(
                    '${widget.products[index].quantity}',
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            GestureDetector(
                onTapDown: (TapDownDetails details) {
                  if (widget.products[index].quantity < 100) {
                    timer =
                        Timer.periodic(const Duration(milliseconds: 200), (t) {
                      setState(() {
                        if (widget.products[index].quantity < 100) {
                          widget.products[index].quantity += 1;
                          updateTotalPrice();
                        } else {
                          timer!.cancel();
                        }
                      });
                    });
                  }
                },
                onTapUp: (TapUpDetails details) {
                  if (widget.products[index].quantity < 100) {
                    timer!.cancel();
                  }
                },
                onTapCancel: () {
                  timer!.cancel();
                },
                onTap: () {
                  if (widget.products[index].quantity < 100) {
                    if (mounted) {
                      setState(() {
                        widget.products[index].quantity += 1;
                        updateTotalPrice();
                      });
                    }
                  }
                },
                child: Icon(FontAwesomeIcons.plus,
                    size: 16,
                    color: widget.products[index].quantity > 100
                        ? linkColor.withOpacity(0.5)
                        : linkColor))
          ]),
        ),
        SizedBox(
          width: width * 0.19,
          child: Center(
              child: Text('\u20B1${widget.products[index].tPrice!}',
                  style: const TextStyle(
                      color: linkColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold))),
        ),
        SizedBox(
          width: width * 0.08,
          child: GestureDetector(
            onTap: () {
              widget
                  .removeProduct(
                      userId: widget.user.userId!,
                      postId: [product.post!.postId!],
                      basketIndex: widget.basketIndex)
                  .whenComplete(() {
                ShoWInfo.showToast('Product has been removed.', 3);
              });
              updateTotalPrice();
            },
            child: const Center(
                child:
                    Icon(FontAwesomeIcons.xmark, size: 14, color: linkColor)),
          ),
        )
      ],
    );
  }
}
