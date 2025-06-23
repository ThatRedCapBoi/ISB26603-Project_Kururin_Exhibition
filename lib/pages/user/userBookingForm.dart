import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart'; // This is your custom User model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth; // <--- CRITICAL FIX: Alias FirebaseAuth

class BookingFormPage extends StatefulWidget {
  final User user; // This refers to your custom User model from models/users.dart
  final Booking? existingBooking;

  const BookingFormPage({super.key, required this.user, this.existingBooking});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  // Changed _boothCtrl to reflect boothPackageID
  final TextEditingController _boothPackageIDCtrl = TextEditingController();
  // Changed _dateCtrl to reflect bookingDate (for the form's display of event date)
  final TextEditingController _eventDateCtrl = TextEditingController();
  // New controller for event time
  final TextEditingController _eventTimeCtrl = TextEditingController();

  final List<String> _availableItems = [ // Renamed for clarity
    'Extra Chairs',
    'Extra Tables',
    'Lounge Seating',
    'Carpet',
    'Brochure Racks',
  ];
  List<dynamic> _selectedItems = []; // Changed to dynamic to match model List<dynamic>

  bool isEdit = false; // Flag to determine if it's an edit or new booking

  @override
  void initState() {
    super.initState();
    if (widget.existingBooking != null) {
      isEdit = true;
      // Update controllers with existing booking data
      _boothPackageIDCtrl.text = widget.existingBooking!.boothPackageID; // Corrected field name
      _eventDateCtrl.text = widget.existingBooking!.eventDate; // Corrected field name
      _eventTimeCtrl.text = widget.existingBooking!.eventTime; // New field
      _selectedItems = List.from(widget.existingBooking!.selectedAddItems); // Corrected field name
    }
  }

  @override
  void dispose() {
    _boothPackageIDCtrl.dispose();
    _eventDateCtrl.dispose();
    _eventTimeCtrl.dispose();
    super.dispose();
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _eventDateCtrl.text = "${picked.toLocal()}".split(' ')[0]; // Format date
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

  Future<void> _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userEmail = auth.FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Cannot save booking.')),
        );
        return;
      }

      // Default values for new required fields if not explicitly collected
      final String bookingStatus = isEdit ? widget.existingBooking!.status : 'Pending';
      final double calculatedTotalPrice = isEdit ? widget.existingBooking!.totalPrice : 0.0; // Implement actual calculation
      final String currentBookingDate = DateTime.now().toIso8601String().split('T')[0]; // Current date for booking record

      final newBooking = Booking(
        id: isEdit ? widget.existingBooking?.id : null, // Corrected to 'id'
        userEmail: userEmail,
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
        final collection = FirebaseFirestore.instance.collection('bookings');

        if (isEdit) {
          await collection.doc(newBooking.id).update(newBooking.toFirestore()); // Corrected to 'id'
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking updated successfully!')),
          );
        } else {
          await collection.add(newBooking.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking added successfully!')),
          );
        }
        Navigator.pop(context, true); // Pop and indicate success
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save booking: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Booking' : 'New Booking'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _boothPackageIDCtrl, // Corrected controller name
                decoration: const InputDecoration(
                  labelText: 'Booth Package ID (e.g., small_booth_package)', // Updated label
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
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
                validator: (value) =>
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
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Please select an event time'
                        : null,
              ),
              const SizedBox(height: 24),
              const Text(
                "Select Additional Items:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._availableItems.map((item) { // Corrected list name
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
    );
  }
}