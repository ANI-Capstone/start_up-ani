import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/estab_order.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/screens/components/widgets/custom_icons.dart';
import 'package:ani_capstone/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActiveOrdersCard extends StatefulWidget {
  const ActiveOrdersCard({Key? key, required this.order}) : super(key: key);

  final EstabOrder order;
  @override
  _ActiveOrdersCardState createState() => _ActiveOrdersCardState();
}

class _ActiveOrdersCardState extends State<ActiveOrdersCard> {
  int items = 2;
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    isExpand();
  }

  void isExpand({bool? expand = false}) {
    if (widget.order.products.length >= 2) {
      if (expand!) {
        setState(() {
          items = widget.order.products.length;
          expanded = true;
        });
      } else {
        setState(() {
          items = 2;
          expanded = false;
        });
      }
    } else {
      setState(() {
        items = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                    text: TextSpan(children: [
                  const WidgetSpan(
                      child: FaIcon(
                    FontAwesomeIcons.tags,
                    color: linkColor,
                    size: 16,
                  )),
                  const WidgetSpan(
                      child: SizedBox(
                    width: 5,
                  )),
                  TextSpan(
                      text: widget.order.orderName,
                      style: const TextStyle(
                          color: linkColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold))
                ])),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                    width: 130,
                    child: Text(
                      Utils.specifiedDateTime(widget.order.dateTime),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          color: linkColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )),
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          DottedBorder(
            color: linkColor.withOpacity(0.7),
            borderType: BorderType.RRect,
            radius: const Radius.circular(5),
            dashPattern: const [2, 2],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          _buildLabel(
                              'Product', 0, ((size.width - 72) * 0.40) + 34),
                          _buildLabel('Qty.', 1, (size.width - 72) * 0.22),
                          _buildLabel('Price', 2, (size.width - 72) * 0.22),
                        ],
                      ),
                    ),
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items,
                        itemBuilder: (context, index) {
                          return _buildProduct(context,
                              widget.order.products[index], size.width, index);
                        }),
                    if (widget.order.products.length > 2 && !expanded)
                      GestureDetector(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                isExpand(expand: !expanded);
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              '+${widget.order.products.length - 2} products',
                              style: const TextStyle(
                                  color: linkColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ))
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: RichText(
                text: TextSpan(children: [
              const TextSpan(
                  text: 'Total Amount:',
                  style: TextStyle(
                    color: linkColor,
                    fontSize: 14,
                  )),
              const WidgetSpan(
                  child: SizedBox(
                width: 5,
              )),
              TextSpan(
                  text:
                      '${Utils.cn}${Utils.numberFormat.format(widget.order.totalAmount)}',
                  style: const TextStyle(
                      color: linkColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold))
            ])),
          ),
          _buildStatus(widget.order.orderStatus!)
        ]),
      ),
    );
  }

  Widget _buildLabel(String label, int index, double space) {
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

  Widget _buildProduct(
      BuildContext context, Product product, double width, int index) {
    final newWidth = width - 72;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
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
          SizedBox(
            width: newWidth * 0.40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
            width: width * 0.19,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Center(
                child: Text(
                  '${product.quantity} ${_buildUnit(product.post!.unit)}',
                  style: const TextStyle(
                      color: linkColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
                child: Text(
                    '${Utils.cn}${Utils.numberFormat.format(product.tPrice!)}',
                    style: const TextStyle(
                        color: linkColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis))),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(int orderStatus) {
    if (orderStatus == 1) {
      return Container(
        height: 25,
        width: double.infinity,
        decoration: BoxDecoration(
            color: acceptedColor, borderRadius: BorderRadius.circular(5)),
        child: const Row(children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              CustomIcons.accepted_order,
              size: 18,
              color: linkColor,
            ),
          ),
          Text('This order has been accepted.',
              style: TextStyle(color: linkColor, fontSize: 13))
        ]),
      );
    } else if (orderStatus == 2) {
      return Container(
        height: 25,
        width: double.infinity,
        decoration: BoxDecoration(
            color: deniedColor, borderRadius: BorderRadius.circular(5)),
        child: const Row(children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              CustomIcons.denied_order,
              size: 18,
              color: Colors.white,
            ),
          ),
          Text('This order has been denied.',
              style: TextStyle(color: Colors.white, fontSize: 13))
        ]),
      );
    }
    return Container(
      height: 25,
      width: double.infinity,
      decoration: BoxDecoration(
          color: pendingColor, borderRadius: BorderRadius.circular(5)),
      child: const Row(children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(
            CustomIcons.pending_order,
            size: 18,
            color: linkColor,
          ),
        ),
        Text('Waiting for order confirmation.',
            style: TextStyle(color: linkColor, fontSize: 13))
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
