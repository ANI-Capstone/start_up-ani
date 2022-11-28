import 'package:ani_capstone/models/product.dart';

class Basket {
  String publisherId;
  List<Product> products;
  int basketIndex;

  Basket(
      {required this.publisherId,
      required this.products,
      required this.basketIndex});
}
