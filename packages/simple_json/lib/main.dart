// class User {
//   final int id;
//   final String name;
//   final int age;

//   const User({required this.id, required this.name, required this.age});

//   Map<String, dynamic> toJson() => {'id': id, 'name': name, 'age': age};

//   static User fromJson(Map<String, dynamic> json) {
//     return User(id: json['id'], name: json['name'], age: json['age']);
//     // try {
//     //   if (json['id'] is! int) {
//     //     throw FormatException(
//     //       "Invalid type for field 'id' in User: ${json['id']}",
//     //     );
//     //   }
//     //   if (json['name'] is! String) {
//     //     throw FormatException(
//     //       "Invalid type for field 'name' in User: ${json['name']}",
//     //     );
//     //   }
//     //   if (json['age'] is! int) {
//     //     throw FormatException(
//     //       "Invalid type for field 'age' in User: ${json['age']}",
//     //     );
//     //   }

//     //   return User(id: json['id'], name: json['name'], age: json['age']);
//     // } catch (e) {
//     //   throw FormatException("Failed to parse User: $e");
//     // }
//   }
// }

import 'package:simple_json/json_reflector.dart';
import 'package:simple_json/main.reflectable.dart';

//run: dart packages/simple_json/lib/main.dart
void main() {
  initializeReflectable();

  var user = User(
    id: 1,
    name: "Anik",
    age: 25,
    posts: [
      Post(id: 1, title: "Post 1", body: "Body 1"),
      Post(id: 2, title: "Post 2", body: "Body 2"),
      Post(id: 3, title: "Post 3", body: "Body 3"),
    ],
    address: Address(city: "Dhaka", country: "Bangladesh"),
  );

  // final json = {
  //   "id": 1,
  //   "full_name": "Anik",
  //   "age": 25,
  //   "list": [1, 2, 3],
  //   "address": {"city": "Dhaka", "country": "Bangladesh"},
  // };

  final json = toJson(user);

  print(json);

  final user2 = fromJson<User>(json);
  print(toJson(user2));
}

@jsonReflector
class User with ReflectableEquality {
  final int id;

  @JsonField(jsonKey: "full_name")
  final String name;
  final int age;
  @JsonField(isList: true, type: Post)
  final List<Post> posts;
  final Address address;

  const User({
    required this.id,
    required this.name,
    required this.age,
    required this.posts,
    required this.address,
  });
}

@jsonReflector
class Address with ReflectableEquality {
  final String city;
  final String country;

  const Address({required this.city, required this.country});
}

@jsonReflector
class Post with ReflectableEquality {
  final int id;
  final String title;
  final String body;

  const Post({required this.id, required this.title, required this.body});
}
