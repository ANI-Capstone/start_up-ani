import 'package:ani_capstone/models/orders.dart';

class Local {
  static List<Orders> _orders = [];

  static setOrders(List<Orders> orders) {
    _orders = orders;
  }

  static addOrder(Orders order) {
    _orders.add(order);
  }

  static List<Orders> getOders() {
    return _orders;
  }
}
