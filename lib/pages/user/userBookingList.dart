import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userNavigation.dart';

import 'package:Project_Kururin_Exhibition/pages/user/userBookingForm.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class BookingListPage extends StatefulWidget {
  final User user;
  final Booking?
  existingBooking; // This may not be used directly if this page only lists bookings

  const BookingListPage({super.key, required this.user, this.existingBooking});

  @override
  State<BookingListPage> createState() => _BookingListPageState(); // Renamed state class for clarity
}

class _BookingListPageState extends State<BookingListPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EventSphere'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('bookings')
                .where('userID', isEqualTo: widget.user.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final bookings = snapshot.data?.docs ?? [];
          if (bookings.isEmpty) {
            return Center(child: Text('No bookings found.'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = Booking.fromFirestore(bookings[index]);
              return ListTile(
                title: Text('Booth: ${booking.boothPackageID}'),
                subtitle: Text(
                  'Event Date: ${booking.eventDate}\nStatus: ${booking.status}',
                ),
                trailing: Icon(Icons.arrow_forward),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BookingFormPage(
                            user: widget.user,
                            existingBooking: booking,
                          ),
                    ),
                  );
                  if (result == true) {
                    setState(() {}); // Refresh the list after editing
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BookingFormPage(
                    user: widget.user,
                    existingBooking: widget.existingBooking,
                  ),
            ),
          ).then((value) {
            if (value == true) {
              // Refresh the list if a booking was added or edited
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
