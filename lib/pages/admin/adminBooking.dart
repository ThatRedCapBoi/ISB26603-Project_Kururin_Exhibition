import 'package:Project_Kururin_Exhibition/pages/admin/adminManageBookings.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/models/booth.dart';
import 'package:Project_Kururin_Exhibition/models/additionalItems.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminAddBooth.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminManageBooths.dart';

class AdminBookingPage extends StatefulWidget {
  final Admin admin;

  const AdminBookingPage({super.key, required this.admin});

  @override
  State<AdminBookingPage> createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere Admin Dashboard'),
        automaticallyImplyLeading: false,
      ),
      // backgroundColor: const Color(0xFFFEFEFA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Booth Booking Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.left,
            ),
            Expanded(child: _boothBookingTable(admin: widget.admin)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBoothManagementOptions(context, widget.admin),
        tooltip: 'Manage Booths',
        child: const Icon(Icons.meeting_room),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
}

class _boothBookingTable extends StatefulWidget {
  final Admin admin;
  const _boothBookingTable({required this.admin});

  @override
  State<_boothBookingTable> createState() => _boothBookingTableState();
}

class _boothBookingTableState extends State<_boothBookingTable> {
  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Stream<List<Booking>> _bookingsStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
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

  @override
  Widget build(BuildContext context) {
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
                      Text("User ID: ${booking.userID}"),
                      Text("User Email: ${booking.userEmail ?? 'N/A'}"),
                      Text("Booking Date: ${booking.bookingDate}"),
                      Text("Event Date: ${booking.eventDate}"),
                      Text("Event Time: ${booking.eventTime}"),
                      Text("Status: ${booking.status}"),
                      Text(
                        "Total Price: RM${booking.totalPrice.toStringAsFixed(2)}",
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
                                    (_) => AdminBookingFormPage(
                                      // user: user!,
                                      admin: widget.admin,
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

Widget boothBookingTable(BuildContext context, {required Admin admin}) {
  return _boothBookingTable(admin: admin);
}

void showBoothManagementOptions(BuildContext context, Admin admin) {
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
              Navigator.pop(context);
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
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminManageBoothsPage(admin: admin),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
