import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/databaseServices/eventSphere_db.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';

import 'package:Project_Kururin_Exhibition/models/users.dart';

class BookingFormPage extends StatefulWidget {
  final User user;
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
    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          widget.existingBooking != null
              ? DateTime.tryParse(widget.existingBooking!.date) ??
                  DateTime.now()
              : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      _dateCtrl.text = pickedDate.toIso8601String().split('T').first;
    }
  }

  void _toggleItem(String item, bool? selected) {
    setState(() {
      selected ??= false;
      if (selected == true && !_selectedItems.contains(item)) {
        _selectedItems.add(item);
      } else if (selected == false && _selectedItems.contains(item)) {
        _selectedItems.remove(item);
      }
    });
  }

  Future<void> _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      final booking = Booking(
        bookID: widget.existingBooking?.bookID,
        userEmail: widget.user.email,
        boothType: _boothCtrl.text.trim(),
        date: _dateCtrl.text.trim(),
        additionalItems: _selectedItems,
      );

      if (widget.existingBooking == null) {
        await EventSphereDB.instance.insertBooking(booking);
        _showMessage('Booking Created');
      } else {
        await EventSphereDB.instance.updateBooking(booking);
        _showMessage('Booking Updated');
      }

      Navigator.pop(context);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingBooking != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Booking' : 'New Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Please enter booth type'
                            : null,
              ),
              const SizedBox(height: 16),
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
                validator:
                    (value) =>
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
