import 'dart:async';

import 'package:ani_capstone/models/user_data.dart';
import 'package:ani_capstone/api/product_post_api.dart';
import 'package:ani_capstone/models/basket.dart';
import 'package:ani_capstone/models/product.dart';
import 'package:ani_capstone/models/user.dart';
import 'package:ani_capstone/screens/components/basket_pages/basket_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";

class BasketScreen extends StatefulWidget {
  UserData user;
  Function(int count, int index) setBadgeCount;

  BasketScreen({Key? key, required this.user, required this.setBadgeCount})
      : super(key: key);

  @override
  _BasketScreenState createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  late String userId;
  late UserData user;

  List<Basket> basket = [];
  List<Product> products = [];

  int fetchState = 0;

  late StreamSubscription listener;

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
    listener.cancel();
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
          final latest = change.doc.data() as Map<String, dynamic>;

          final newProduct = Product.fromJson(latest);

          bool contain = false;

          if (basket.isNotEmpty) {
            for (var baskt in basket) {
              if (baskt.products.any(
                  (product) => newProduct.productId == product.productId)) {
                contain = true;
                break;
              }
            }
          }

          if (contain) return;

          addNewProduct(newProduct).then((product) {
            bool added = false;
            int sum = 0;
            if (basket.isNotEmpty) {
              for (int i = 0; i < basket.length; i++) {
                if (basket[i].publisherId == product.publisher.userId) {
                  if (mounted) {
                    setState(() {
                      basket[i].products.add(product);
                    });
                  }
                  added = true;
                }
                sum += basket[i].products.length;
              }
            }

            if (mounted && !added) {
              setState(() {
                basket.add(Basket(
                    publisherId: product.publisher.userId!,
                    products: [product],
                    basketIndex: 0));

                sum += basket[basket.length - 1].products.length;

                if (fetchState != 1) {
                  fetchState = 1;
                }
              });
            }

            if (mounted) {
              setState(() {
                widget.setBadgeCount(sum, 0);
              });
            }
          });
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
    ProductPost.getUserBasket(userId: userId).then((value) {
      if (value.isNotEmpty) {
        fetchProducts(value).then((products) {
          final productGroup =
              groupBy(products, (Product obj) => obj.publisher.userId).values;

          for (int i = 0; i < productGroup.length; i++) {
            final product = productGroup.toList()[i];

            basket.add(Basket(
                publisherId: product[0].publisher.userId!,
                products: product,
                basketIndex: i));
          }

          setState(() {
            fetchState = 1;
            widget.setBadgeCount(value.length, 0);
          });
        });
      } else {
        setState(() {
          fetchState = 2;
        });
      }

      productListener();
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
            height: height - 230,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: basket.length,
                  itemBuilder: (context, index) {
                    return buildProduct(basket[index]);
                  }),
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

  Widget buildProduct(Basket basket) {
    final user = User(
        name: widget.user.name,
        photoUrl: widget.user.photoUrl!,
        userId: widget.user.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: BasketCard(
        user: user,
        products: basket.products,
        removeProduct: <Future>(
            {required String userId,
            required List<String> postId,
            required int basketIndex}) {
          return removeProduct(
              userId: userId, postId: postId, basketIndex: basketIndex);
        },
        basketIndex: basket.basketIndex,
      ),
    );
  }
}
