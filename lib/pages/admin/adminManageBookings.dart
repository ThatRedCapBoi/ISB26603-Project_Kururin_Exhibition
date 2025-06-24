import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookingFormPage extends StatefulWidget {
  final Admin admin;
  final Booking? existingBooking;

  const AdminBookingFormPage({
    super.key,
    required this.admin,
    this.existingBooking,
  });

  @override
  State<AdminBookingFormPage> createState() => _AdminBookingFormPageState();
}

class _AdminBookingFormPageState extends State<AdminBookingFormPage> {
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

  @override
  void initState() {
    super.initState();
    if (widget.existingBooking != null) {
      isEdit = true;
      _boothPackageIDCtrl.text = widget.existingBooking!.boothPackageID;
      _eventDateCtrl.text = widget.existingBooking!.eventDate;
      _eventTimeCtrl.text = widget.existingBooking!.eventTime;
      _selectedItems = List.from(widget.existingBooking!.selectedAddItems);
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

      final String bookingStatus =
          isEdit ? widget.existingBooking!.status : 'Pending';
      final double calculatedTotalPrice =
          isEdit ? widget.existingBooking!.totalPrice : 0.0;
      final String currentBookingDate =
          DateTime.now().toIso8601String().split('T')[0];

      final newBooking = Booking(
        id: isEdit ? widget.existingBooking?.id : null,
        userEmail: isEdit ? widget.existingBooking?.userEmail ?? '' : '',
        boothPackageID: _boothPackageIDCtrl.text.trim(),
        selectedAddItems: _selectedItems,
        bookingDate: currentBookingDate,
        eventDate: _eventDateCtrl.text.trim(),
        eventTime: _eventTimeCtrl.text.trim(),
        status: bookingStatus,
        totalPrice: calculatedTotalPrice,
        userID: isEdit ? widget.existingBooking?.userID ?? '' : '',
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
    int selectedIndex = 2; // Default to Bookings tab for admin

    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere Admin Dashboard'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),

      // backgroundColor: const Color(0xFFFEFEFA),
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _boothPackageIDCtrl,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  hintText: '(e.g., small_booth_package)',
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
                icon: Icon(isEdit ? Icons.save : Icons.check),
                onPressed: _saveBooking,
                label: Text(isEdit ? 'Update Booking' : 'Submit Booking'),
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
