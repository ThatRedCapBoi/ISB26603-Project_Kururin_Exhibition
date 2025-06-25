import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart'; // This is your custom User model

import 'package:Project_Kururin_Exhibition/widgets/components.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userNavigation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as auth; // <--- CRITICAL FIX: Alias FirebaseAuth

class BookingFormPage extends StatefulWidget {
  final User
  user; // This refers to your custom User model from models/users.dart
  final Booking? existingBooking;

  const BookingFormPage({super.key, required this.user, this.existingBooking});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _boothPackageIDCtrl = TextEditingController();
  final TextEditingController _eventDateCtrl = TextEditingController();
  final TextEditingController _eventTimeCtrl = TextEditingController();

  final List<String> _availableItems = [
    'Extra Chairs',
    'Extra Tables',
    'Lounge Seating',
    'Carpet',
    'Brochure Racks',
  ];
  List<dynamic> _selectedItems = [];

  bool isEdit = false;

  // List to hold fetched booth packages
  List<Map<String, dynamic>> _boothPackages = [];
  bool _isLoadingPackages = true;

  @override
  void initState() {
    super.initState();
    _fetchBoothPackages();
    if (widget.existingBooking != null) {
      isEdit = true;
      _boothPackageIDCtrl.text = widget.existingBooking!.boothPackageID;
      _eventDateCtrl.text = widget.existingBooking!.eventDate;
      _eventTimeCtrl.text = widget.existingBooking!.eventTime;
      _selectedItems = List.from(widget.existingBooking!.selectedAddItems);
    }
  }

  Future<void> _fetchBoothPackages() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('boothPackages').get();
      setState(() {
        _boothPackages =
            snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'name': data['boothName'] ?? doc.id,
                'price': data['boothPrice'] ?? 0.0,
              };
            }).toList();
        _isLoadingPackages = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPackages = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch booth packages: $e')),
      );
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

  Future<void> _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final userEmail = auth.FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in. Cannot save booking.'),
          ),
        );
        return;
      }

      final String bookingStatus =
          isEdit ? widget.existingBooking!.status : 'Pending';
      final double calculatedTotalPrice =
          isEdit ? widget.existingBooking!.totalPrice : 0.0;
      final String currentBookingDate =
          DateTime.now().toIso8601String().split('T')[0];

      final newBooking = Booking(
        id: isEdit ? widget.existingBooking?.id : null,
        userEmail: userEmail,
        boothPackageID: _boothPackageIDCtrl.text.trim(),
        selectedAddItems: _selectedItems,
        bookingDate: currentBookingDate,
        eventDate: _eventDateCtrl.text.trim(),
        eventTime: _eventTimeCtrl.text.trim(),
        status: bookingStatus,
        totalPrice: calculatedTotalPrice,
        userID: widget.user.id!,
      );

      try {
        final collection = FirebaseFirestore.instance.collection('bookings');

        if (isEdit) {
          await collection.doc(newBooking.id).update(newBooking.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking updated successfully!')),
          );
        } else {
          await collection.add(newBooking.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking added successfully!')),
          );
        }
        Navigator.pop(context, true);
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
    int selectedIndex = 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('EventSphere'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                isEdit ? 'Edit Booking' : 'New Booking',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 16),

              // Booth Package Dropdown
              _isLoadingPackages
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                    value:
                        _boothPackageIDCtrl.text.isNotEmpty
                            ? _boothPackageIDCtrl.text
                            : null,
                    decoration: const InputDecoration(
                      labelText: 'Booth Package',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _boothPackages
                            .map(
                              (pkg) => DropdownMenuItem<String>(
                                value: pkg['id'],
                                child: Text(pkg['name'] ?? pkg['id']),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _boothPackageIDCtrl.text = value ?? '';
                      });
                    },
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Please select a booth package'
                                : null,
                  ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _eventDateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Event Date',
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
                controller: _eventTimeCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Event Time',
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
                return CheckboxListTile(
                  title: Text(item),
                  value: _selectedItems.contains(item),
                  onChanged: (value) => _toggleItem(item, value),
                );
              }).toList(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(
                  isEdit ? Icons.save : Icons.check,
                  color: Colors.white,
                ),
                onPressed: _saveBooking,
                label: Text(
                  isEdit ? 'Update Booking' : 'Submit Booking',
                  style: TextStyle(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
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
