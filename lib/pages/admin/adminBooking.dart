import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart'; // Booking model
import 'package:Project_Kururin_Exhibition/models/admin.dart'; // Admin model
import 'package:Project_Kururin_Exhibition/pages/user/userBookingForm.dart'; // Assumed BookingFormPage for editing
import 'package:Project_Kururin_Exhibition/models/users.dart'; // User model
import 'package:Project_Kururin_Exhibition/models/booth.dart'; // BoothPackage model
import 'package:Project_Kururin_Exhibition/models/additionalItems.dart'; // AdditionalItem model

// Import the new booth management pages
import 'package:Project_Kururin_Exhibition/pages/admin/adminAddBooth.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminManageBoothsPage.dart'; // You will create this

class AdminBookingPage extends StatefulWidget {
  final Admin admin;

  const AdminBookingPage({super.key, required this.admin});

  @override
  State<AdminBookingPage> createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage> {
  int _selectedIndex = 2;

  // Helper function to show a SnackBar message
  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  // Stream to listen for real-time updates from the 'bookings' collection.
  Stream<List<Booking>> _bookingsStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList(),
        );
  }

  // Function to delete a booking directly via Firestore
  Future<void> _deleteBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .delete();
      _showSnackBar('Booking deleted successfully.');
    } catch (e) {
      _showSnackBar(
        'Failed to delete booking: $e',
        backgroundColor: Colors.red,
      );
      print('Error deleting booking: $e'); // Log the error for debugging
    }
  }

  // Fetches a single BoothPackage by its ID directly from Firestore.
  Future<String> _getBoothPackageName(String packageId) async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('boothPackages')
              .doc(packageId)
              .get();
      if (docSnapshot.exists) {
        final boothPackage = BoothPackage.fromFirestore(docSnapshot);
        return boothPackage
            .boothName; // Corrected to boothName from packageName, based on booth.dart
      }
      return 'Unknown Booth';
    } catch (e) {
      print('Error fetching booth package name for $packageId: $e');
      return 'Error Booth';
    }
  }

  // Fetches a single AdditionalItem by its ID directly from Firestore.
  Future<String> _getAdditionalItemName(String itemId) async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('additionalItems')
              .doc(itemId)
              .get();
      if (docSnapshot.exists) {
        final item = AdditionalItem.fromFirestore(docSnapshot);
        return item.itemName;
      }
      return 'Unknown Item';
    } catch (e) {
      print('Error fetching additional item name for $itemId: $e');
      return 'Error Item';
    }
  }

  // Helper function to format the list of additional items for display.
  Future<String> _formatAdditionalItems(List<dynamic> items) async {
    if (items.isEmpty) {
      return 'None';
    }
    List<String> itemStrings = [];
    for (var itemData in items) {
      // Assuming itemData can either be a String (if stored simply) or a Map (if it includes quantity)
      if (itemData is Map<String, dynamic> &&
          itemData.containsKey('itemID') &&
          itemData.containsKey('quantity')) {
        String itemId = itemData['itemID'] as String;
        int quantity = itemData['quantity'] as int;
        String itemName = await _getAdditionalItemName(
          itemId,
        ); // Use direct fetch
        itemStrings.add('$itemName (x$quantity)');
      } else if (itemData is String) {
        // If additional items are stored as simple strings, you might need to fetch their full names
        // or assume the string itself is the name. For simplicity, we'll use the string directly.
        itemStrings.add(itemData);
      }
    }
    return itemStrings.join(', ');
  }

  // Fetches a user by their email directly from Firestore.
  Future<User?> _getUserByEmail(String email) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        return User.fromFirestore(querySnapshot.docs.first);
      }
      return null; // User not found
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Function to show the booth management options
  void _showBoothManagementOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add New Booth'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminAddBoothPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Manage Existing Booths'),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                // Navigate to a page where you can list, edit, and delete booths
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminManageBoothsPage(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere Admin Dashboard'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFEFEFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16),
            Text(
              'Booth Booking Management ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(child: boothBookingCardList(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBoothManagementOptions,
        child: const Icon(Icons.meeting_room), // Icon for booth management
        tooltip: 'Manage Booths',
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Assuming onAdminDestinationSelected is a global or accessible function
          // You might need to import it or define it in a utility file
          onAdminDestinationSelected(context, index, widget.admin);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Widget to display a list of booth bookings using Cards.
  Widget boothBookingCardList(BuildContext context) {
    return StreamBuilder<List<Booking>>(
      stream: _bookingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No bookings found.'));
        } else {
          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: FutureBuilder<String>(
                    future: _getBoothPackageName(
                      booking.boothPackageID,
                    ), // Use boothPackageID
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Booth: Loading...");
                      } else if (snapshot.hasError) {
                        return const Text("Booth: Error");
                      } else {
                        return Text(
                          "Booth: ${snapshot.data ?? 'Unknown Booth'}",
                        );
                      }
                    },
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("User ID: ${booking.userID ?? 'N/A'}"),
                      Text(
                        "User Email: ${booking.userEmail ?? 'N/A'}",
                      ), // Display user email
                      Text("Booking Date: ${booking.bookingDate}"),
                      Text("Event Date: ${booking.eventDate}"),
                      Text("Event Time: ${booking.eventTime}"),
                      Text("Status: ${booking.status}"),
                      Text(
                        "Total Price: \RM${booking.totalPrice.toStringAsFixed(2)}",
                      ),
                      FutureBuilder<String>(
                        future: _formatAdditionalItems(
                          booking.selectedAddItems,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text("Items: Loading...");
                          } else if (snapshot.hasError) {
                            return const Text("Items: Error");
                          } else {
                            return Text("Items: ${snapshot.data ?? 'None'}");
                          }
                        },
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          User? user;
                          // Prioritize fetching user by userID if available and reliable
                          // Otherwise, fallback to email or handle as per your User model's unique identifier.
                          if (booking.userID.isNotEmpty) {
                            try {
                              // Assuming 'userID' in Booking corresponds to the document ID in 'users' collection
                              DocumentSnapshot userDoc =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(booking.userID)
                                      .get();
                              if (userDoc.exists) {
                                user = User.fromFirestore(userDoc);
                              } else if (booking.userEmail != null &&
                                  booking.userEmail!.isNotEmpty) {
                                // Fallback to email if user ID lookup fails
                                user = await _getUserByEmail(
                                  booking.userEmail!,
                                );
                              }
                            } catch (e) {
                              print(
                                'Error fetching user by ID for booking edit: $e',
                              );
                              // Fallback to email if error occurs with ID
                              if (booking.userEmail != null &&
                                  booking.userEmail!.isNotEmpty) {
                                user = await _getUserByEmail(
                                  booking.userEmail!,
                                );
                              }
                            }
                          } else if (booking.userEmail != null &&
                              booking.userEmail!.isNotEmpty) {
                            // If userID is not present, try fetching by email
                            user = await _getUserByEmail(booking.userEmail!);
                          }

                          if (user != null) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => BookingFormPage(
                                      user:
                                          user!, // <-- FIX: Use ! to assert non-null
                                      existingBooking: booking,
                                    ),
                              ),
                            );
                          } else {
                            _showSnackBar(
                              'User not found for this booking. Cannot edit.',
                              backgroundColor: Colors.orange,
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (booking.id != null) {
                            _deleteBooking(booking.id!);
                          } else {
                            _showSnackBar(
                              'Booking ID is missing.',
                              backgroundColor: Colors.orange,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
