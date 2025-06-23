// lib/models/users.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String username;
  // Add any other boolean fields you might have, e.g., final bool isActivated;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.username,
    // Add if applicable: this.isActivated = false,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print('--- Debugging User.fromFirestore ---');
    print('Document ID: ${doc.id}');
    print('Raw Data: $data');
    // If you have other boolean fields, print their types/values too
    // print('Type of data[\'isActivated\']: ${data['isActivated']?.runtimeType}');
    // print('Value of data[\'isActivated\']: ${data['isActivated']}');

    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      username: data['username'] ?? '',
      // If you had 'isActivated', handle it safely:
      // isActivated: (data['isActivated'] is bool) ? data['isActivated'] : (data['isActivated'].toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'username': username,
      // 'isActivated': isActivated,
    };
  }
}
