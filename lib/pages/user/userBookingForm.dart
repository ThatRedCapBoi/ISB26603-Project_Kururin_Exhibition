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

  bool isEdit = false; // Flag to determine if it's an edit or new booking

  @override
  void initState() {
    super.initState();
    if (widget.existingBooking != null) {
      isEdit = true;
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
        _dateCtrl.text = "${picked.toLocal()}".split(' ')[0]; // Format date
      });
    }
  }

  Future<void> _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Get current user's email from Firebase Auth
      // Use 'auth.FirebaseAuth' because 'FirebaseAuth' would clash with the 'User' class
      final userEmail = auth.FirebaseAuth.instance.currentUser?.email;

      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in. Cannot save booking.')),
        );
        return;
      }

      final newBooking = Booking(
        // bookID is handled by Firestore, only provided if editing
        bookID: isEdit ? widget.existingBooking?.bookID : null,
        userEmail: userEmail, // Use authenticated user's email
        boothType: _boothCtrl.text.trim(),
        additionalItems: _selectedItems,
        date: _dateCtrl.text.trim(),
      );

      try {
        final collection = FirebaseFirestore.instance.collection('bookings');

        if (isEdit) {
          // Update existing booking
          await collection.doc(newBooking.bookID).update(newBooking.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking updated successfully!')),
          );
        } else {
          // Add new booking
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
                controller: _boothCtrl,
                decoration: const InputDecoration(
                  labelText: 'Booth Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Please enter booth type'
                        : null,
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
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Please select a date'
                        : null,
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