import 'package:simple_json_example/order.dart';

void main() {
  final order = Order(
    name: 'Order 1',
    id: '123',
    products: [
      Product(name: "Product 1", id: '123', amount: 1),
      Product(name: "Product 2", id: '456', amount: 2),
      Product(name: "Product 3", id: '789', amount: 3),
    ],
    amount: 99.99,
  );

  // toMap() is an extension method
  final map = order.toMap();
  map['amount'] = 199;
  print(map);

  // fromMap is a top-level function
  final orderFromMap = Order.fromMap(map);
  print(orderFromMap.products.last.name);

  // copyWith is an extension method
  final updated = order.copyWith(amount: 199.99);
}
