import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userNavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:Project_Kururin_Exhibition/models/booth.dart'; // Import your BoothPackage model
import 'package:Project_Kururin_Exhibition/models/additionalItems.dart'; // Import your AdditionalItem model

class BookingFormPage extends StatefulWidget {
  final User user;
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

  List<String> _availableItems = []; // This will now hold names of additional items
  List<AdditionalItem> _availableAdditionalItems = []; // To store fetched AdditionalItem objects
  List<dynamic> _selectedItems = []; // Stores names of selected items
  double _totalPrice = 0.0; // State variable to hold the calculated total price

  bool isEdit = false;
  int selectedIndex = 1; // Assuming 'Bookings' is the second tab

  List<Map<String, dynamic>> _boothPackages = [];
  bool _isLoadingPackages = true;
  bool _isLoadingAdditionalItems = true;

  @override
  void initState() {
    super.initState();
    _fetchBoothPackages();
    _fetchAdditionalItems(); // Fetch additional items and their prices
    if (widget.existingBooking != null) {
      isEdit = true;
      _boothPackageIDCtrl.text = widget.existingBooking!.boothPackageID;
      _eventDateCtrl.text = widget.existingBooking!.eventDate;
      _eventTimeCtrl.text = widget.existingBooking!.eventTime;
      _selectedItems = List.from(widget.existingBooking!.selectedAddItems);
      _totalPrice = widget.existingBooking!.totalPrice; // Initialize with existing total price
    } else {
      _boothPackageIDCtrl.text = ''; // Initialize to empty for new bookings to force selection
    }
    // _calculateTotalPrice will be called after booth packages and additional items are loaded
  }

  Future<void> _fetchBoothPackages() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('boothPackages').get(); //
      setState(() {
        _boothPackages =
            snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'name': data['boothName'] ?? doc.id,
                'price': (data['boothPrice'] ?? 0).toDouble(), // Ensure price is double
              };
            }).toList();
        _isLoadingPackages = false;
        // If it's a new booking, set a default selected booth package ID if available
        if (!isEdit && _boothPackages.isNotEmpty && _boothPackageIDCtrl.text.isEmpty) {
          _boothPackageIDCtrl.text = _boothPackages.first['id'];
        }
        _calculateTotalPrice(); // Recalculate after packages are loaded
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

  Future<void> _fetchAdditionalItems() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('additionalItems').get(); //
      setState(() {
        _availableAdditionalItems =
            snapshot.docs.map((doc) => AdditionalItem.fromFirestore(doc)).toList();
        _availableItems = _availableAdditionalItems.map((item) => item.itemName).toList();
        _isLoadingAdditionalItems = false;
        _calculateTotalPrice(); // Recalculate after additional items are loaded
      });
    } catch (e) {
      setState(() {
        _isLoadingAdditionalItems = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch additional items: $e')),
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

  void _toggleItem(String itemName, bool? value) {
    setState(() {
      if (value == true) {
        _selectedItems.add(itemName);
      } else {
        _selectedItems.remove(itemName);
      }
    });
    _calculateTotalPrice(); // Recalculate price whenever items change
  }

  Future<void> _calculateTotalPrice() async {
    if (_isLoadingPackages || _isLoadingAdditionalItems) {
      // Wait for data to be loaded
      return;
    }

    double currentTotal = 0.0;

    // 1. Get Booth Package Price
    if (_boothPackageIDCtrl.text.isNotEmpty) {
      final selectedPackage = _boothPackages.firstWhere(
        (pkg) => pkg['id'] == _boothPackageIDCtrl.text,
        orElse: () => {'price': 0.0}, // Default to 0 if not found
      );
      currentTotal += selectedPackage['price'] as double;
    }

    // 2. Get Additional Items Prices
    for (String selectedItemName in _selectedItems) {
      final item = _availableAdditionalItems.firstWhere(
        (additionalItem) => additionalItem.itemName == selectedItemName,
        orElse: () => AdditionalItem(itemName: '', description: '', price: 0.0), // Default to 0 if not found
      );
      currentTotal += item.price;
    }

    setState(() {
      _totalPrice = currentTotal;
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
        totalPrice: _totalPrice, // Use the calculated total price
        userID: widget.user.id,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere'),
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
              const SizedBox(height: 16),

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
                                child: Text('${pkg['name']} (RM ${pkg['price'].toStringAsFixed(2)})'),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _boothPackageIDCtrl.text = value ?? '';
                      });
                      _calculateTotalPrice(); // Recalculate when booth package changes
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
              _isLoadingAdditionalItems
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: _availableItems.map((item) {
                        return CheckboxListTile(
                          title: Text(item),
                          value: _selectedItems.contains(item),
                          onChanged: (value) => _toggleItem(item, value),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 24),
              // Display the calculated total price
              Text(
                'Total Price: RM ${_totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
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