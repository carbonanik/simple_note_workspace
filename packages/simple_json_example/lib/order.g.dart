// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'order.dart';

// **************************************************************************
// JsonGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures

extension OrderExtension on Order {
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'products': products.map((e) => e.toMap()).toList(),
      'amount': amount,
    };
  }

  Order copyWith({
    String? name,
    String? id,
    List<Product>? products,
    double? amount,
  }) {
    return Order(
      name: name ?? this.name,
      id: id ?? this.id,
      products: products ?? this.products,
      amount: amount ?? this.amount,
    );
  }
}

Order OrderFromMap(Map<String, dynamic> map) {
  return Order(
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
            return ProductFromMap(e);
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

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures

extension ProductExtension on Product {
  Map<String, dynamic> toMap() {
    return {'name': name, 'id': id, 'amount': amount};
  }

  Product copyWith({String? name, String? id, double? amount}) {
    return Product(
      name: name ?? this.name,
      id: id ?? this.id,
      amount: amount ?? this.amount,
    );
  }
}

Product ProductFromMap(Map<String, dynamic> map) {
  return Product(
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
