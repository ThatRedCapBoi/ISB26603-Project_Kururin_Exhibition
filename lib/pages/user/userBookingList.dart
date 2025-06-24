import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userNavigation.dart';

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
  // Renamed state class
  int _selectedIndex = 1;
  final _formKey = GlobalKey<FormState>();
  // Corrected controller name
  final TextEditingController _boothPackageIDCtrl = TextEditingController();
  // Corrected controller name and added event time controller
  final TextEditingController _eventDateCtrl = TextEditingController();
  final TextEditingController _eventTimeCtrl = TextEditingController();

  final List<String> _availableItems = [
    // Renamed for clarity
    'Extra Chairs',
    'Extra Tables',
    'Lounge Seating',
    'Carpet',
    'Brochure Racks',
  ];
  List<dynamic> _selectedItems =
      []; // Changed to dynamic to match model List<dynamic>

  bool get isEdit => widget.existingBooking != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingBooking != null) {
      _boothPackageIDCtrl.text =
          widget.existingBooking!.boothPackageID; // Corrected field name
      _eventDateCtrl.text =
          widget.existingBooking!.eventDate; // Corrected field name
      _eventTimeCtrl.text = widget.existingBooking!.eventTime; // New field
      _selectedItems = List.from(
        widget.existingBooking!.selectedAddItems,
      ); // Corrected field name
    }
  }

  @override
  void dispose() {
    _boothPackageIDCtrl.dispose();
    _eventDateCtrl.dispose();
    _eventTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101), // Increased last date
    );
    if (picked != null) {
      setState(() {
        _eventDateCtrl.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _eventTimeCtrl.text = picked.format(context);
      });
    }
  }

  void _toggleItem(String item, bool? value) {
    setState(() {
      if (value == true) {
        _selectedItems.add(item);
      } else {
        _selectedItems.remove(item);
      }
    });
  }

  void _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      final user = auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in. Cannot save booking.'),
          ),
        );
        return;
      }

      // Default values for new required fields if not explicitly collected
      final String bookingStatus =
          isEdit ? widget.existingBooking!.status : 'Pending';
      final double calculatedTotalPrice =
          isEdit ? widget.existingBooking!.totalPrice : 0.0; // Placeholder
      final String currentBookingDate =
          DateTime.now().toIso8601String().split('T')[0];

      final newBooking = Booking(
        id: widget.existingBooking?.id, // Corrected to 'id'
        userEmail: user.email!,
        boothPackageID: _boothPackageIDCtrl.text.trim(), // Corrected field name
        selectedAddItems: _selectedItems, // Corrected field name
        bookingDate: currentBookingDate, // Booking creation date
        eventDate: _eventDateCtrl.text.trim(), // Event date from form
        eventTime: _eventTimeCtrl.text.trim(), // Event time from form
        status: bookingStatus,
        totalPrice: calculatedTotalPrice,
        userID: widget.user.id!, // Assuming your User model has an 'id' field
      );

      try {
        if (isEdit) {
          if (newBooking.id != null) {
            // Corrected to 'id'
            await FirebaseFirestore.instance
                .collection('bookings')
                .doc(newBooking.id) // Corrected to 'id'
                .update(newBooking.toFirestore());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Booking Updated Successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: No booking ID for update.')),
            );
          }
        } else {
          await FirebaseFirestore.instance
              .collection('bookings')
              .add(newBooking.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking Submitted Successfully!')),
          );
        }
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving booking: ${e.toString()}')),
        );
        print('Booking save error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Booking' : 'New Booking'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _boothPackageIDCtrl, // Corrected controller name
                decoration: const InputDecoration(
                  labelText: 'Booth Package ID', // Updated label
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Please enter booth package ID'
                            : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _eventDateCtrl, // Corrected controller name
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Event Date', // Updated label
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Please select an event date'
                            : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _eventTimeCtrl, // New controller for time
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Event Time', // New label
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Please select an event time'
                            : null,
              ),
              const SizedBox(height: 24),
              const Text(
                "Select Additional Items:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._availableItems.map((item) {
                // Corrected list name
                return CheckboxListTile(
                  title: Text(item),
                  value: _selectedItems.contains(item),
                  onChanged: (value) => _toggleItem(item, value),
                );
              }).toList(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(isEdit ? Icons.save : Icons.check),
                onPressed: _saveBooking,
                label: Text(isEdit ? 'Update Booking' : 'Submit Booking'),
              ),
            ],
          ),
        ),
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
            label: 'Booking',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
