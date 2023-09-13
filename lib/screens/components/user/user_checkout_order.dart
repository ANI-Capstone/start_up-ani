import 'package:ani_capstone/api/product_order_api.dart';
import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/estab_order.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/utils.dart';
import 'package:fdottedline_nullsafety/fdottedline__nullsafety.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CheckoutOrder extends StatefulWidget {
  const CheckoutOrder({Key? key, required this.order}) : super(key: key);

  final EstabOrder order;
  @override
  _CheckoutOrderState createState() => _CheckoutOrderState();
}

class _CheckoutOrderState extends State<CheckoutOrder> {
  int? paymentMethod;

  double? totalPayment;
  double? transactionFee;
  EstabOrder? order;

  @override
  void initState() {
    computeInitials();
    super.initState();
    order = widget.order;
  }

  void computeInitials() {
    if (mounted) {
      setState(() {
        transactionFee = widget.order.totalAmount * Policy.transactionFee;
        totalPayment = widget.order.totalAmount + transactionFee!;
      });
    }
  }

  void placeOrder() {
    order!.totalPayment = totalPayment;
    order!.transactionFee = transactionFee;
    ProductOrderApi.addOrder(
            userId: widget.order.orderFrom.userId!, order: order!)
        .whenComplete(() {
      ShoWInfo.showToast('Order has been checkout successfully.', 3);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: userBgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            FontAwesomeIcons.arrowLeft,
            color: linkColor,
            size: 20,
          ),
        ),
        title: const Text('CHECKOUT',
            style: TextStyle(color: linkColor, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            addressCard(),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Ordered',
                            style: TextStyle(
                                color: linkColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          productsCard(size)
                        ]),
                  ),
                  FDottedLine(
                    width: double.infinity,
                    dottedLength: 2,
                    space: 3,
                    color: linkColor.withOpacity(0.7),
                  ),
                  paymentOptions(),
                  FDottedLine(
                    width: double.infinity,
                    dottedLength: 2,
                    space: 3,
                    color: linkColor.withOpacity(0.7),
                  ),
                  totalsCard(),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget totalsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _buildTotal('Product Amount:',
              '${Utils.cn}${Utils.numberFormat.format(widget.order.totalAmount)}'),
          _buildTotal('Transaction Fee:',
              '${Utils.cn}${Utils.numberFormat.format(transactionFee)}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: 170,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Payment:',
                    style: TextStyle(color: linkColor, fontSize: 14),
                  ),
                  Text('${Utils.cn}${Utils.numberFormat.format(totalPayment)}',
                      style: const TextStyle(
                          color: starColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: GestureDetector(
              onTap: () {
                ShoWInfo.showUpDialog(context,
                    title: 'Place Order',
                    message: 'Are you sure you want to place order?',
                    action1: 'Yes',
                    btn1: () {
                      Navigator.of(context).pop();
                    },
                    action2: 'Cancel',
                    btn2: () {
                      Navigator.of(context).pop();
                    });
              },
              child: Container(
                alignment: Alignment.center,
                width: 170,
                height: 35,
                decoration: BoxDecoration(
                    color: linkColor, borderRadius: BorderRadius.circular(5)),
                child: const Text(
                  'Place Order',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildTotal(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        width: 170,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: linkColor, fontSize: 12),
            ),
            Text(amount,
                style: const TextStyle(
                    color: linkColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  Widget paymentOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Methods',
              style: TextStyle(
                  color: linkColor, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Transform.scale(
                    scale: 0.8,
                    child: Radio(
                      activeColor: linkColor,
                      value: 0,
                      groupValue: paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = int.parse(value.toString());
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  'Cash on Delivery',
                  style: TextStyle(color: linkColor, fontSize: 14),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget productsCard(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildLabel('Product(s)', 0, (size.width - 72) * 0.54),
              _buildLabel('Qty.', 1, (size.width - 72) * 0.19),
              const Expanded(
                child: Center(
                  child: Text(
                    'Price',
                    style: TextStyle(
                        color: linkColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 3,
          ),
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order.products.length >= 2 ? 2 : 1,
              itemBuilder: (context, index) {
                return _buildProduct(
                    context, widget.order.products[index], size.width, index);
              }),
          if (widget.order.products.length > 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '+ ${widget.order.products.length - 2} products',
                style: const TextStyle(
                    color: linkColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: RichText(
                text: TextSpan(children: [
              const TextSpan(
                  text: 'Product Amount:',
                  style: TextStyle(
                    color: linkColor,
                    fontSize: 12.5,
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold))
            ])),
          )
        ],
      ),
    );
  }

  Widget addressCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.locationDot,
                          size: 16,
                          color: linkColor,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Delivery Address',
                          style: TextStyle(
                              color: linkColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      widget.order.orderFrom.name,
                      style: const TextStyle(color: linkColor, fontSize: 12),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.order.location.completeAddress!,
                      style: const TextStyle(
                          color: linkColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 18,
                      width: 48,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: starColor),
                      child: const Center(
                          child: Text(
                        'Default',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      )),
                    )
                  ]),
            ),
            GestureDetector(
              onTap: () {
                ShoWInfo.showToast('Cannot be changed at this moment.', 2);
              },
              child: const SizedBox(
                width: 55,
                child: Center(
                  child: Text(
                    'Change',
                    style: TextStyle(color: starColor, fontSize: 12),
                  ),
                ),
              ),
            )
          ],
        ),
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
                  fontSize: 12, color: linkColor, fontWeight: FontWeight.bold),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: linkColor,
                      fontWeight: FontWeight.bold),
                ),
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
          SizedBox(
            width: newWidth * 0.54,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    product.post!.name,
                    style: const TextStyle(
                        color: linkColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: newWidth * 0.19,
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
