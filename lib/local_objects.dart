import 'package:ani_capstone/models/order.dart';

class Local {
  static List<Order> _orders = [];

  static setOrders(List<Order> orders) {
    _orders = orders;
  }

  static addOrder(Order order) {
    _orders.add(order);
  }

  static List<Order> getOders() {
    return _orders;
  }
}
