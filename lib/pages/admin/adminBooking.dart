import 'package:Project_Kururin_Exhibition/pages/admin/adminManageBookings.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminAddBooth.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminManageBooths.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminAddAdditionalItem.dart'; // <--- ADD THIS LINE

class AdminBookingPage extends StatefulWidget {
  final Admin admin;

  const AdminBookingPage({super.key, required this.admin});

  @override
  State<AdminBookingPage> createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage> {
  int _selectedIndex = 2; // Keep this consistent with your navigation bar index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere Admin Dashboard'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.tune), // Or a more suitable icon
        //     onPressed: () => showBoothManagementOptions(context, widget.admin),
        //     tooltip: 'Manage Booths & Items',
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Management Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _boothBookingTable(admin: widget.admin)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBoothManagementOptions(context, widget.admin),
        tooltip: 'Manage Booths & Items',
        child: Icon(Icons.add_business),
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
  __boothBookingTableState createState() => __boothBookingTableState();
}

class __boothBookingTableState extends State<_boothBookingTable> {
  @override
  Widget build(BuildContext context) {
    // This is a simplified placeholder. Your actual _boothBookingTable logic goes here.
    // It should stream data from Firestore's 'bookings' collection.
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No bookings found.'));
        }

        final bookings =
            snapshot.data!.docs
                .map((doc) => Booking.fromFirestore(doc))
                .toList();

        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  'Booking ID: ${booking.id ?? 'N/A'}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User: ${booking.userEmail}'),
                    Text('Booth ID: ${booking.boothPackageID}'),
                    Text('Date: ${booking.eventDate} ${booking.eventTime}'),
                    Text(
                      'Total Price: RM ${booking.totalPrice.toStringAsFixed(2)}',
                    ),
                    Text(
                      'Item: ${booking.selectedAddItems.toString().replaceAll('[', '').replaceAll(']', '')}',
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            booking.status == "Rejected"
                                ? Colors.red.shade700
                                : booking.status == "Pending"
                                ? Colors.yellow.shade700
                                : booking.status == "Confirmed"
                                ? Colors.green.shade800
                                : Colors.deepPurple.shade200,
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
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to AdminManageBookingsPage for editing
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AdminBookingFormPage(
                              admin: widget.admin,
                              existingBooking: booking,
                            ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Function to show booth and item management options
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminManageBoothsPage(admin: admin),
                ),
              );
            },
          ),
          ListTile(
            // <--- ADD THIS NEW LIST TILE FOR ADDITIONAL ITEMS
            leading: const Icon(Icons.library_add), // Choose a suitable icon
            title: const Text('Add New Additional Item'),
            onTap: () {
              Navigator.pop(context); // Close the bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const AdminAddAdditionalItemPage(), // Navigate to the new page
                ),
              );
            },
          ),
          // You might want to add an option to 'Manage Existing Additional Items' here as well
          // if you create a corresponding page for it.
        ],
      );
    },
  );
}
