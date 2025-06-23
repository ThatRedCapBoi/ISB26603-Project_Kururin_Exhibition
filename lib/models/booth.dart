// lib/models/booth.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BoothPackage { // Renamed from boothPackage to BoothPackage for Dart convention
  final String? id; // Firestore Document ID
  final String boothName;
  final String boothDescription;
  final String boothCapacity;
  final String boothImage; // Assuming this might be a URL to image in Firebase Storage or a static asset path

  BoothPackage({
    this.id,
    required this.boothName,
    required this.boothDescription,
    required this.boothCapacity,
    required this.boothImage,
  });

  // Factory constructor to create a BoothPackage from a Firestore DocumentSnapshot
  factory BoothPackage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BoothPackage(
      id: doc.id,
      boothName: data['boothName'] ?? '',
      boothDescription: data['boothDescription'] ?? '',
      boothCapacity: data['boothCapacity'] ?? '',
      boothImage: data['boothImage'] ?? '',
    );
  }

  // Method to convert BoothPackage to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'boothName': boothName,
      'boothDescription': boothDescription,
      'boothCapacity': boothCapacity,
      'boothImage': boothImage,
    };
  }
}

// You can remove the static getBoothPackages() method if you're fetching from Firestore
// static List<boothPackage> getBoothPackages() { ... }