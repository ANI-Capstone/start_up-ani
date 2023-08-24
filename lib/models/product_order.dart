class ProductOrder {
  final String productName;
  final int quantity;
  final int unit;

  ProductOrder(
      {required this.productName, required this.quantity, required this.unit});

  Map<String, dynamic> toJson() =>
      {'productName': productName, 'quantity': quantity, 'unit': unit};
}
