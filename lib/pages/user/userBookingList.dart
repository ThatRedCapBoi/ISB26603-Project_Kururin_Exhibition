import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:flutter/material.dart';

import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/databaseServices/EventSphere_db.dart';

import 'package:Project_Kururin_Exhibition/pages/user/userBookingForm.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userNavigation.dart';

class BookingListPage extends StatefulWidget {
  final User user;
  const BookingListPage({super.key, required this.user});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  List<Booking> _bookings = [];

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final data = await EventSphereDB.instance.getBookingsByUser(
      widget.user.email,
    );
    setState(() => _bookings = data);
  }

  void _navigateToForm({Booking? booking}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BookingFormPage(user: widget.user, existingBooking: booking),
      ),
    );
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        automaticallyImplyLeading: false,
      ),
      body:
          _bookings.isEmpty
              ? const Center(child: Text("You haven't made any bookings yet."))
              : ListView.builder(
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text("Booth: ${booking.boothType}"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: ${booking.date}"),
                          Text("Items: ${booking.additionalItems.join(', ')}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToForm(booking: booking),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        tooltip: 'New Booking',
        child: const Icon(Icons.add),
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
