import 'package:simple_json_annotation/simple_json_annotation.dart';

part 'order.g.dart';

@jsonGen
class Order {
  String name;
  String id;
  List<Product> products;
  double amount;
  Order({
    required this.name,
    required this.id,
    required this.products,
    required this.amount,
  });

  factory Order.fromMap(Map<String, dynamic> json) => OrderFromMap(json);
}

@jsonGen
class Product {
  String name;
  String id;
  double amount;
  Product({required this.name, required this.id, required this.amount});

  factory Product.fromMap(Map<String, dynamic> json) => ProductFromMap(json);
}
