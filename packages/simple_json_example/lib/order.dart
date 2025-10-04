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
}

@jsonGen
class Product {
  String name;
  String id;
  double amount;
  Product({required this.name, required this.id, required this.amount});
}
