// lib/models/admin.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id;
  final String name;
  final String email;
  final bool isAdmin; // To match the 'isAdmin: true' field in Firestore
  final String? username;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = true, // Admins typically have this true by default
    this.username,
  });

  factory Admin.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print('--- Debugging Admin.fromFirestore ---');
    print('Document ID: ${doc.id}');
    print('Raw Data: $data');
    print('Type of data[\'isAdmin\']: ${data['isAdmin']?.runtimeType}');
    print('Value of data[\'isAdmin\']: ${data['isAdmin']}');

    // Add a more robust check here if you suspect mixed types or nulls
    bool resolvedIsAdmin;
    if (data['isAdmin'] is bool) {
      resolvedIsAdmin = data['isAdmin'];
    } else if (data['isAdmin'] is String) {
      // This handles cases where it might be "true" or "false" string
      resolvedIsAdmin = data['isAdmin'].toLowerCase() == 'true';
      print('Converted isAdmin from String to bool: $resolvedIsAdmin');
    } else {
      // Default to false if the type is unexpected or null
      resolvedIsAdmin = false;
      print('Warning: Unexpected type for isAdmin. Defaulting to false.');
    }

    return Admin(
      id: doc.id,
      name: data['name'] ?? 'Admin',
      email: data['email'] ?? '',
      isAdmin: resolvedIsAdmin, // Use the safely resolved value
      username: data['username'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
      'username': username,
    };
  }
}