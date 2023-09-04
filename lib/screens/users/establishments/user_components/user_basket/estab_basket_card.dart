import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EstabBasketCard extends StatefulWidget {
  const EstabBasketCard(
      {Key? key,
      required this.user,
      required this.products,
      required this.selectedItemsCount,
      required this.basketIndex,
      required this.removeProduct})
      : super(key: key);

  final User user;
  final List<Product> products;
  final VoidCallback selectedItemsCount;
  final int basketIndex;
  final Function<Future>(
      {required String userId,
      required List<String> postId,
      required int basketIndex}) removeProduct;

  @override
  State<EstabBasketCard> createState() => _EstabBasketCardState();
}

class _EstabBasketCardState extends State<EstabBasketCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Column(children: [
        Row(children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: primaryColor,
              backgroundImage:
                  Image.network(widget.products[0].publisher.photoUrl).image),
          const SizedBox(width: 10),
          Text(
            widget.products[0].publisher.name,
            style: const TextStyle(
                color: linkColor, fontSize: 14, fontWeight: FontWeight.bold),
          )
        ]),
        const SizedBox(
          height: 10,
        ),
        ListView.builder(
            shrinkWrap: true,
            itemCount: widget.products.length,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: ((context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: DottedBorder(
                  color: linkColor.withOpacity(0.7),
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(5),
                  dashPattern: const [2, 2],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Row(
                          children: [
                            Checkbox(
                              value: widget.products[index].checkBox,
                              checkColor: Colors.white,
                              activeColor: linkColor,
                              onChanged: (value) {
                                setState(() {
                                  widget.products[index].checkBox =
                                      !widget.products[index].checkBox!;

                                  widget.selectedItemsCount();
                                  // if (checkAll) checkAll = false;

                                  // updateTotalPrice();
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              side:
                                  const BorderSide(width: 1, color: linkColor),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              child: Image.network(
                                widget.products[index].post!.images[0],
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                                errorBuilder: (context, url, error) =>
                                    const Icon(Icons.error,
                                        size: 12, color: linkColor),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  widget.products[index].post!.name,
                                  style: const TextStyle(
                                      color: linkColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                '\u20B1${widget.products[index].post!.price.toString()} / ${_buildUnit(widget.products[index].post!.unit)}',
                                style: const TextStyle(
                                    color: linkColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                widget
                                    .removeProduct(
                                        userId: widget.user.userId!,
                                        postId: [
                                          widget.products[index].post!.postId!
                                        ],
                                        basketIndex: widget.basketIndex)
                                    .whenComplete(() {
                                  ShoWInfo.showToast(
                                      'Product has been removed.', 3);
                                });
                              },
                              child: const SizedBox(
                                width: 30,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: FaIcon(
                                    FontAwesomeIcons.xmark,
                                    color: linkColor,
                                    size: 16,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                ),
              );
            }))
      ]),
    );
  }

  String _buildUnit(String unit) {
    if (unit == 'Kilogram') {
      return 'kl.';
    } else if (unit == 'Gram') {
      return 'g.';
    } else if (unit == 'Pcs') {
      return 'pcs.';
    }

    return 'unit';
  }
}
