import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart'; // Make sure this model has toFirestore()
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firebase Firestore import
import 'package:firebase_auth/firebase_auth.dart' as auth; // Added Firebase Auth import

class BookingListPage extends StatefulWidget {
  final User user;
  final Booking? existingBooking;

  const BookingListPage({super.key, required this.user, this.existingBooking});

  @override
  State<BookingListPage> createState() => _BookingListPage();
}

class _BookingListPage extends State<BookingListPage> {
  final _formKey = GlobalKey<FormState>();
  final _boothCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  final List<String> _items = [
    'Extra Chairs',
    'Extra Tables',
    'Lounge Seating',
    'Carpet',
    'Brochure Racks',
  ];
  List<String> _selectedItems = [];

  bool get isEdit => widget.existingBooking != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingBooking != null) {
      _boothCtrl.text = widget.existingBooking!.boothType;
      _dateCtrl.text = widget.existingBooking!.date;
      _selectedItems = List.from(widget.existingBooking!.additionalItems);
    }
  }

  @override
  void dispose() {
    _boothCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text = "${picked.day}/${picked.month}/${picked.year}";
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
          const SnackBar(content: Text('User not logged in. Cannot save booking.')),
        );
        return;
      }

      final newBooking = Booking(
        // For new bookings, bookID will be null and Firestore will generate one
        // For updates, the existing bookID (Firestore Doc ID) is passed
        bookID: widget.existingBooking?.bookID, // Assuming bookID stores Firestore doc ID
        userEmail: user.email!, // Use current authenticated user's email
        boothType: _boothCtrl.text.trim(),
        additionalItems: _selectedItems,
        date: _dateCtrl.text.trim(),
      );

      try {
        if (isEdit) {
          // Update existing booking in Firestore
          if (newBooking.bookID != null) {
            await FirebaseFirestore.instance
                .collection('bookings')
                .doc(newBooking.bookID) // Use the Firestore document ID
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
          // Add new booking to Firestore
          await FirebaseFirestore.instance.collection('bookings').add(newBooking.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking Submitted Successfully!')),
          );
        }
        Navigator.pop(context, true); // Pop and indicate success
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
                controller: _boothCtrl,
                decoration: const InputDecoration(
                  labelText: 'Booth Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter booth type' : null,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Booking Date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please select a date' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                "Select Additional Items:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._items.map((item) {
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