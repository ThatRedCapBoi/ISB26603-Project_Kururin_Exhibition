import 'package:cloud_firestore/cloud_firestore.dart';

// Represents an additional item that can be booked with a booth package.
class AdditionalItem {
  final String? id; // Document ID from Firestore
  final String itemName;
  final String description;
  final double price;

  AdditionalItem({
    this.id,
    required this.itemName,
    required this.description,
    required this.price,
  });

  // Factory constructor to create an AdditionalItem from a Firestore document.
  factory AdditionalItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdditionalItem(
      id: doc.id, // Assign the document ID
      itemName: data['itemName'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(), // Ensure price is double
    );
  }

  // Convert an AdditionalItem object to a map for Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'itemName': itemName,
      'description': description,
      'price': price,
    };
  }
}
