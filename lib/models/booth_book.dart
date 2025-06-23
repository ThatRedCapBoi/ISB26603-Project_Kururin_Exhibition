// lib/models/booth_book.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for DocumentSnapshot

class Booking {
  final String? bookID; // Changed from int? to String? to store Firestore document ID
  final String userEmail;
  final String boothType;
  final List<String> additionalItems; // Stored as List<String>
  final String date;

  Booking({
    this.bookID, // bookID is now the Firestore document ID (optional for new bookings)
    required this.userEmail,
    required this.boothType,
    required this.additionalItems,
    required this.date,
  });

  // Factory constructor to create a Booking object from a Firestore DocumentSnapshot
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Booking(
      bookID: doc.id, // Set bookID to the Firestore document ID
      userEmail: data['userEmail'] ?? '',
      boothType: data['boothType'] ?? '',
      // Ensure additionalItems is correctly cast from Firestore List<dynamic> to List<String>
      additionalItems: List<String>.from(data['additionalItems'] ?? []),
      date: data['date'] ?? '',
    );
  }

  // Method to convert Booking object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userEmail': userEmail,
      'boothType': boothType,
      'additionalItems': additionalItems, // Stored as a native List in Firestore
      'date': date,
    };
  }

  // You can remove the old toMap and fromMap methods if you are fully migrating to Firebase
  // If you still have sqflite dependencies for other parts, keep them, but they won't be used for bookings.
  /*
  Map<String, dynamic> toMap() => {
        'bookID': bookID, // This would be for sqflite auto-incrementing int
        'userEmail': userEmail,
        'boothType': boothType,
        'additionalItems': additionalItems.join(','), // For storing as string in sqflite
        'date': date,
      };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        bookID: map['bookID'],
        userEmail: map['userEmail'],
        boothType: map['boothType'],
        additionalItems: map['additionalItems'].split(','),
        date: map['date'],
      );
  */
}