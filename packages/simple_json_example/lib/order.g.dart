// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'order.dart';

// **************************************************************************
// JsonGenerator
// **************************************************************************

class OrderGen {
  final String name;
  final String id;
  final List<Product> products;
  final double amount;
  const OrderGen({
    required this.name,
    required this.id,
    required this.products,
    required this.amount,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'products': products.map((e) => e.toMap()).toList(),
      'amount': amount,
    };
  }

  factory OrderGen.fromMap(Map<String, dynamic> map) {
    return OrderGen(
      name: (() {
        try {
          final value = map['name'];
          if (value == null) throw Exception('Field is null');
          if (value is! String)
            throw Exception('Expected String but got ${value.runtimeType}');
          return value;
        } catch (e) {
          throw Exception('Error parsing field "name" of type "String": $e');
        }
      })(),
      id: (() {
        try {
          final value = map['id'];
          if (value == null) throw Exception('Field is null');
          if (value is! String)
            throw Exception('Expected String but got ${value.runtimeType}');
          return value;
        } catch (e) {
          throw Exception('Error parsing field "id" of type "String": $e');
        }
      })(),
      products: (() {
        try {
          final list = map['products'];
          if (list == null) throw Exception('Field is null');
          if (list is! List)
            throw Exception('Expected List but got ${list.runtimeType}');
          return list.map((e) {
            try {
              if (e is! Map<String, dynamic>)
                throw Exception(
                  'Expected Map<String, dynamic> but got ${e.runtimeType}',
                );
              return ProductGen.fromMap(e);
            } catch (e) {
              throw Exception('Error parsing list item to Product: $e');
            }
          }).toList();
        } catch (e) {
          throw Exception(
            'Error parsing field "products" of type "List<Product>": $e',
          );
        }
      })(),
      amount: (() {
        try {
          final value = map['amount'];
          if (value == null) throw Exception('Field is null');
          if (value is! double)
            throw Exception('Expected double but got ${value.runtimeType}');
          return value;
        } catch (e) {
          throw Exception('Error parsing field "amount" of type "double": $e');
        }
      })(),
    );
  }
  OrderGen copyWith({
    String? name,
    String? id,
    List<Product>? products,
    double? amount,
  }) {
    return OrderGen(
      name: name ?? this.name,
      id: id ?? this.id,
      products: products ?? this.products,
      amount: amount ?? this.amount,
    );
  }
}

class ProductGen {
  final String name;
  final String id;
  final double amount;
  const ProductGen({
    required this.name,
    required this.id,
    required this.amount,
  });
  Map<String, dynamic> toMap() {
    return {'name': name, 'id': id, 'amount': amount};
  }

  factory ProductGen.fromMap(Map<String, dynamic> map) {
    return ProductGen(
      name: (() {
        try {
          final value = map['name'];
          if (value == null) throw Exception('Field is null');
          if (value is! String)
            throw Exception('Expected String but got ${value.runtimeType}');
          return value;
        } catch (e) {
          throw Exception('Error parsing field "name" of type "String": $e');
        }
      })(),
      id: (() {
        try {
          final value = map['id'];
          if (value == null) throw Exception('Field is null');
          if (value is! String)
            throw Exception('Expected String but got ${value.runtimeType}');
          return value;
        } catch (e) {
          throw Exception('Error parsing field "id" of type "String": $e');
        }
      })(),
      amount: (() {
        try {
          final value = map['amount'];
          if (value == null) throw Exception('Field is null');
          if (value is! double)
            throw Exception('Expected double but got ${value.runtimeType}');
          return value;
        } catch (e) {
          throw Exception('Error parsing field "amount" of type "double": $e');
        }
      })(),
    );
  }
  ProductGen copyWith({String? name, String? id, double? amount}) {
    return ProductGen(
      name: name ?? this.name,
      id: id ?? this.id,
      amount: amount ?? this.amount,
    );
  }
}
