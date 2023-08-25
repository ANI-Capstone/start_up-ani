class ProductOrder {
  final String productName;
  final int quantity;
  final String unit;
  final int unitId;

  ProductOrder(
      {required this.productName,
      required this.quantity,
      required this.unit,
      required this.unitId});

  Map<String, dynamic> toJson() =>
      {'productName': productName, 'quantity': quantity, 'unit': unit};
}
