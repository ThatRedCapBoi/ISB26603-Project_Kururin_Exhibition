import 'package:flutter/material.dart';

import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/databaseServices/EventSphere_db.dart';

import 'package:Project_Kururin_Exhibition/pages/user/userBookingForm.dart';

class BookingListPage extends StatefulWidget {
  final String userEmail;

  const BookingListPage({super.key, required this.userEmail});

  @override
  State<BookingListPage> createState() => _BookingListPageState();
}

class _BookingListPageState extends State<BookingListPage> {
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final data = await EventSphereDB.instance.getBookingsByUser(
      widget.userEmail,
    );
    setState(() => _bookings = data);
  }

  void _navigateToForm({Booking? booking}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BookingFormPage(
              userEmail: widget.userEmail,
              existingBooking: booking,
            ),
      ),
    );
    _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
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
    );
  }
}
