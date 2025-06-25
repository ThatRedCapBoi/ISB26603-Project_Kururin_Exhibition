import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/models/booth.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/models/additionalItems.dart';

import 'package:Project_Kururin_Exhibition/pages/user/userNavigation.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userBookingForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class BookingListPage extends StatefulWidget {
  final User user;
  final Booking? existingBooking;

  const BookingListPage({super.key, required this.user, this.existingBooking});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  int _selectedIndex = 1;

  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  // Only show bookings for the current user
  Stream<List<Booking>> _bookingsStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userID', isEqualTo: widget.user.id)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList(),
        );
  }

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
      print('Error deleting booking: $e');
    }
  }

  Future<String> _getBoothPackageName(String packageId) async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance
              .collection('boothPackages')
              .doc(packageId)
              .get();
      if (docSnapshot.exists) {
        final boothPackage = BoothPackage.fromFirestore(docSnapshot);
        return boothPackage.boothName;
      }
      return 'Unknown Booth';
    } catch (e) {
      print('Error fetching booth package name for $packageId: $e');
      return 'Error Booth';
    }
  }

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

  Future<String> _formatAdditionalItems(List<dynamic> items) async {
    if (items.isEmpty) {
      return 'None';
    }
    List<String> itemStrings = [];
    for (var itemData in items) {
      if (itemData is Map<String, dynamic> &&
          itemData.containsKey('itemID') &&
          itemData.containsKey('quantity')) {
        String itemId = itemData['itemID'] as String;
        int quantity = itemData['quantity'] as int;
        String itemName = await _getAdditionalItemName(itemId);
        itemStrings.add('$itemName (x$quantity)');
      } else if (itemData is String) {
        itemStrings.add(itemData);
      }
    }
    return itemStrings.join(', ');
  }

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
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

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
                    future: _getBoothPackageName(booking.boothPackageID),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          "Booth: Loading...",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Text(
                          "Booth: Error",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        return Text(
                          "Booth: ${snapshot.data ?? 'Unknown Booth'}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    },
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Booking Date: ${booking.bookingDate}"),
                      Text("Event Date: ${booking.eventDate}"),
                      Text("Event Time: ${booking.eventTime}"),
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
                      SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade200,

                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Status: ${booking.status}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          User? user;
                          if (booking.userID.isNotEmpty) {
                            try {
                              DocumentSnapshot userDoc =
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(booking.userID)
                                      .get();
                              if (userDoc.exists) {
                                user = User.fromFirestore(userDoc);
                              } else if (booking.userEmail != null &&
                                  booking.userEmail!.isNotEmpty) {
                                user = await _getUserByEmail(
                                  booking.userEmail!,
                                );
                              }
                            } catch (e) {
                              print(
                                'Error fetching user by ID for booking edit: $e',
                              );
                              if (booking.userEmail != null &&
                                  booking.userEmail!.isNotEmpty) {
                                user = await _getUserByEmail(
                                  booking.userEmail!,
                                );
                              }
                            }
                          } else if (booking.userEmail != null &&
                              booking.userEmail!.isNotEmpty) {
                            user = await _getUserByEmail(booking.userEmail!);
                          }

                          if (user != null) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => BookingFormPage(
                                      user: user!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EventSphere'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'Booth Booking List',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(child: boothBookingCardList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      BookingFormPage(user: widget.user, existingBooking: null),
            ),
          ).then((value) {
            if (value == true) {
              setState(() {});
            }
          });
        },
        child: Icon(Icons.add),
        tooltip: 'New Booking',
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          onUserDestinationSelected(context, index, widget.user);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
