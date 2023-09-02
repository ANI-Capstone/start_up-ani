import 'dart:async';

import 'package:ani_capstone/constants.dart';
import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/models/basket.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/basket_pages/basket_card.dart';
import 'package:ani_capstone/screens/users/establishments/user_components/user_basket/estab_basket_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";

class EstabBasket extends StatefulWidget {
  const EstabBasket(
      {Key? key,
      required this.user,
      required this.updateAddedProducts,
      required this.setBadgeCount})
      : super(key: key);

  final UserData user;
  final Function(List<Product> products) updateAddedProducts;
  final Function(int count, int index) setBadgeCount;

  @override
  _EstabBasketState createState() => _EstabBasketState();
}

class _EstabBasketState extends State<EstabBasket> {
  late String userId;
  late UserData user;

  List<Basket> basket = [];
  List<Product> products = [];

  int fetchState = 0;

  bool createOrder = false;
  bool checkAll = false;

  StreamSubscription? listener;

  int selectedItems = 0;

  @override
  void initState() {
    super.initState();

    userId = widget.user.id!;
    user = widget.user;

    fetchBasket();
  }

  @override
  void dispose() {
    super.dispose();
    basket.clear();
    if (listener != null) listener!.cancel();
  }

  void selectAllItems(bool value) {
    setState(() {
      checkAll = value;

      int itemsCount = 0;

      for (int i = 0; i < basket.length; i++) {
        for (int j = 0; j < basket[i].products.length; j++) {
          checkAll
              ? basket[i].products[j].checkBox = true
              : basket[i].products[j].checkBox = false;

          itemsCount += 1;
        }
      }

      checkAll ? selectedItems = itemsCount : selectedItems = 0;
    });
  }

  void selectedItemsCount() {
    int items = 0;

    for (int i = 0; i < basket.length; i++) {
      for (int j = 0; j < basket[i].products.length; j++) {
        if (basket[i].products[j].checkBox!) {
          items += 1;
        } else {
          if (checkAll) {
            setState(() {
              checkAll = false;
            });
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        selectedItems = items;
      });
    }

    if (selectedItems > 0 && createOrder) return;

    selectedItems > 0 ? toggleCreateOrder(true) : toggleCreateOrder(false);
  }

  void toggleCreateOrder(bool toggle) {
    if (mounted) {
      setState(() {
        createOrder = toggle;
      });
    }
  }

  Future removeProduct(
      {required String userId,
      required List<String> postId,
      required int basketIndex}) {
    bool done = false;

    int sum = 0;
    List<Product> products = [];

    for (var product in basket[basketIndex].products) {
      if (postId.contains(product.productId)) {
        products.add(product);
      }
      done = true;
    }

    if (mounted && done) {
      setState(() {
        for (var product in products) {
          basket[basketIndex].products.remove(product);
        }
      });
    }

    if (done) {
      if (basket[basketIndex].products.isEmpty) {
        if (mounted) {
          setState(() {
            basket.removeAt(basketIndex);
          });
        }
      }

      if (basket.isEmpty) {
        if (mounted) {
          setState(() {
            fetchState = 2;
          });
        }
      }
    }

    if (basket.isNotEmpty) {
      sum += basket[basketIndex].products.length;
    } else {
      sum = 0;
    }

    if (mounted) {
      setState(() {
        widget.setBadgeCount(sum, 0);
      });
    }

    return ProductPost.removeToBasket(userId: userId, productIds: postId);
  }

  void productListener() async {
    final basketRef = ProductPost.basketStream(userId: userId);

    listener = basketRef.listen((event) async {
      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          fetchBasket();
        }
      }
    });
  }

  Future<Product> addNewProduct(Product product) {
    return ProductPost.getProducts(productList: [product.productId])
        .then((value) {
      product.post = value[0];
      product.tPrice = value[0].price.round();

      return product;
    });
  }

  Future<List<Product>> fetchProducts(List<Product> products) {
    return ProductPost.getProducts(productList: generateProductList(products))
        .then((post) {
      for (int i = 0; i < products.length; i++) {
        for (int j = 0; j < products.length; j++) {
          if (products[i].productId == post[j].postId) {
            products[i].post = post[j];
            products[i].tPrice = post[j].price.round();
          }
        }
      }
      return products;
    });
  }

  List<String> generateProductList(List<Product> products) {
    return products.map((product) => product.productId).toList();
  }

  void fetchBasket() async {
    if (listener == null) productListener();
    ProductPost.getUserBasket(userId: userId).then((value) {
      if (value.isNotEmpty) {
        List<Basket> temp = [];

        fetchProducts(value).then((products) {
          final productGroup =
              groupBy(products, (Product obj) => obj.publisher.userId).values;

          for (int i = 0; i < productGroup.length; i++) {
            final product = productGroup.toList()[i];

            temp.add(Basket(
                publisherId: product[0].publisher.userId!,
                products: product,
                basketIndex: i));
          }

          setState(() {
            basket = temp;
            fetchState = 1;
            widget.setBadgeCount(value.length, 0);
          });
        });

        widget.updateAddedProducts(value);
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
    final height = MediaQuery.of(context).size.height;

    return fetchState != 1
        ? statusBuilder()
        : SizedBox(
            height: height - 187,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: basket.length,
                        itemBuilder: (context, index) {
                          return buildProduct(basket[index]);
                        }),
                  ),
                ),
                if (createOrder)
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffDDDDDD),
                          blurRadius: 2.0,
                          spreadRadius: 2.0,
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Checkbox(
                            value: checkAll,
                            checkColor: Colors.white,
                            activeColor: linkColor,
                            onChanged: (value) {
                              selectAllItems(value!);
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            side: const BorderSide(width: 1, color: linkColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          Expanded(
                              child: Text(
                            '($selectedItems) Items',
                            style: TextStyle(
                                color: linkColor, fontWeight: FontWeight.bold),
                          )),
                          Container(
                            height: 36,
                            width: 160,
                            decoration: BoxDecoration(
                                color: linkColor,
                                borderRadius: BorderRadius.circular(5)),
                            child: const Center(
                              child: Text(
                                'Create Order',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          );
  }

  Widget statusBuilder() {
    if (fetchState == 2) {
      return SizedBox(
          height: (MediaQuery.of(context).size.height) * 0.6,
          child: const Center(child: Text('Basket is empty.')));
    } else if (fetchState == -1) {
      return SizedBox(
          height: (MediaQuery.of(context).size.height) * 0.6,
          child: const Center(
              child: Text('An error occurred, please try again.')));
    } else {
      return SizedBox(
          height: (MediaQuery.of(context).size.height) * 0.6,
          child: const Center(child: CircularProgressIndicator()));
    }
  }

  Widget buildProduct(Basket basket) {
    final user = User(
        name: widget.user.name,
        photoUrl: widget.user.photoUrl!,
        userId: widget.user.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: EstabBasketCard(
        user: user,
        products: basket.products,
        basketIndex: basket.basketIndex,
        removeProduct: <Future>(
            {required String userId,
            required List<String> postId,
            required int basketIndex}) {
          return removeProduct(
              userId: userId, postId: postId, basketIndex: basketIndex);
        },
        selectedItemsCount: () {
          selectedItemsCount();
        },
      ),
    );
  }
}
