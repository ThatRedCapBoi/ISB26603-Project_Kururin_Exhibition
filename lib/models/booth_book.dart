import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a booking made by a user.
class Booking {
  final String? id; // Document ID from Firestore
  final String? userEmail;
  final String boothPackageID; // Renamed from boothType to match Firebase field 'boothPackageID'
  final List<dynamic> selectedAddItems; // Matches 'selectedAddItems' from Firebase
  final String bookingDate; // Renamed from 'date' to match 'bookingDate' from Firebase
  final String eventDate; // New field from Firebase snapshot
  final String eventTime; // New field from Firebase snapshot
  final String status; // New field from Firebase snapshot
  final double totalPrice; // New field from Firebase snapshot
  final String userID; // New field from Firebase snapshot, renamed from 'userId' to 'userID'

  Booking({
    this.id,
    this.userEmail,
    required this.boothPackageID,
    required this.selectedAddItems,
    required this.bookingDate,
    required this.eventDate,
    required this.eventTime,
    required this.status,
    required this.totalPrice,
    required this.userID,
  });

  // Factory constructor to create a Booking object from a Firestore DocumentSnapshot
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Ensure 'selectedAddItems' is a List, default to empty list if null
    List<dynamic> items = [];
    if (data['selectedAddItems'] is List) {
      items = List<dynamic>.from(data['selectedAddItems']);
    }

    return Booking(
      id: doc.id, // Assign the document ID
      userEmail: data['userEmail'], // This field isn't in your image, but keeping it if it's elsewhere
      boothPackageID: data['boothPackageID'] ?? '', // Match Firebase field name
      selectedAddItems: items,
      bookingDate: data['bookingDate'] ?? '', // Match Firebase field name
      eventDate: data['eventDate'] ?? '', // Match Firebase field name
      eventTime: data['eventTime'] ?? '', // Match Firebase field name
      status: data['status'] ?? '', // Match Firebase field name
      totalPrice: (data['totalPrice'] ?? 0).toDouble(), // Match Firebase field name
      userID: data['userID'] ?? '', // Match Firebase field name (case-sensitive)
    );
  }

  // Method to convert Booking object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'bookingDate': bookingDate,
      'boothPackageID': boothPackageID,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'selectedAddItems': selectedAddItems,
      'status': status,
      'totalPrice': totalPrice,
      'userID': userID, // Ensure case matches Firestore
      if (userEmail != null) 'userEmail': userEmail, // Only include if userEmail is relevant for new bookings
    };
  }
}
