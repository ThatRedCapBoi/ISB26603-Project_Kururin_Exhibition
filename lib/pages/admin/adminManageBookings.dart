import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Project_Kururin_Exhibition/models/booth.dart'; // Import your BoothPackage model
import 'package:Project_Kururin_Exhibition/models/additionalItems.dart'; // Import your AdditionalItem model

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
  // Removed _statusController as it's no longer needed with DropdownButtonFormField
  // final TextEditingController _statusController = TextEditingController(); // Controller for status

  // --- NEW: Status variable and options list ---
  String? _selectedStatus; // To hold the selected status
  final List<String> _statusOptions = ['Pending', 'Confirmed', 'Rejected'];
  // --- END NEW ---

  List<String> _availableItems = []; // This will hold names of fetched additional items
  List<AdditionalItem> _availableAdditionalItems = []; // To store fetched AdditionalItem objects
  List<dynamic> _selectedItems = []; // Stores names of selected items

  double _totalPrice = 0.0; // State variable for total price
  bool isEdit = false;
  int selectedIndex = 2; // Assuming 'Bookings' is the third tab for admin

  List<Map<String, dynamic>> _boothPackages = [];
  bool _isLoadingPackages = true;
  bool _isLoadingAdditionalItems = true;


  @override
  void initState() {
    super.initState();
    _fetchBoothPackages();
    _fetchAdditionalItems(); // Fetch additional items from Firestore

    if (widget.existingBooking != null) {
      isEdit = true;
      _boothPackageIDCtrl.text = widget.existingBooking!.boothPackageID;
      _eventDateCtrl.text = widget.existingBooking!.eventDate;
      _eventTimeCtrl.text = widget.existingBooking!.eventTime;
      // Initialize _selectedStatus with existing booking status
      _selectedStatus = widget.existingBooking!.status;
      _selectedItems = List.from(widget.existingBooking!.selectedAddItems);
      _totalPrice = widget.existingBooking!.totalPrice;
    } else {
      _boothPackageIDCtrl.text = ''; // Initialize to empty for new bookings to force selection
      _selectedStatus = 'Pending'; // Default status for new bookings
    }
    // _calculateTotalPrice will be called after booth packages and additional items are loaded
  }

  @override
  void dispose() {
    _boothPackageIDCtrl.dispose();
    _eventDateCtrl.dispose();
    _eventTimeCtrl.dispose();
    // Dispose _statusController is removed
    super.dispose();
  }

  Future<void> _fetchBoothPackages() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('boothPackages').get();
      setState(() {
        _boothPackages = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['boothName'] ?? doc.id,
            'price': (data['boothPrice'] ?? 0).toDouble(),
          };
        }).toList();
        _isLoadingPackages = false;
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

  // New function to fetch additional items from Firestore
  Future<void> _fetchAdditionalItems() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('additionalItems').get();
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
        orElse: () => {'price': 0.0},
      );
      currentTotal += selectedPackage['price'] as double;
    }

    // 2. Get Additional Items Prices
    for (String selectedItemName in _selectedItems) {
      final item = _availableAdditionalItems.firstWhere(
        (additionalItem) => additionalItem.itemName == selectedItemName,
        orElse: () => AdditionalItem(itemName: '', description: '', price: 0.0),
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

      // Use _selectedStatus directly
      final String bookingStatus = _selectedStatus ?? 'Pending';
      final String currentBookingDate = DateTime.now().toIso8601String().split('T')[0];

      final updatedBooking = Booking(
        id: widget.existingBooking?.id,
        userEmail: widget.existingBooking?.userEmail, // Retain existing user email
        boothPackageID: _boothPackageIDCtrl.text.trim(),
        selectedAddItems: _selectedItems,
        bookingDate: currentBookingDate,
        eventDate: _eventDateCtrl.text.trim(),
        eventTime: _eventTimeCtrl.text.trim(),
        status: bookingStatus, // Use the selected status
        totalPrice: _totalPrice,
        userID: widget.existingBooking?.userID ?? '', // Retain existing userID
      );

      try {
        final collection = FirebaseFirestore.instance.collection('bookings');

        if (isEdit) {
          await collection.doc(updatedBooking.id).update(updatedBooking.toFirestore());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This form is for editing existing bookings.')),
          );
          return;
        }
        Navigator.pop(context, true); // Go back after saving
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
        title: const Text('EventSphere Admin Dashboard'),
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
                    value: _boothPackageIDCtrl.text.isNotEmpty
                            ? _boothPackageIDCtrl.text
                            : null,
                    decoration: const InputDecoration(
                      labelText: 'Booth Package',
                      border: OutlineInputBorder(),
                    ),
                    items: _boothPackages
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
                    validator: (value) => value == null || value.trim().isEmpty
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
                validator: (value) => value == null || value.trim().isEmpty
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
                validator: (value) => value == null || value.trim().isEmpty
                            ? 'Please select an event time'
                            : null,
              ),
              const SizedBox(height: 24),
              // --- NEW: DropdownButtonFormField for Booking Status ---
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Booking Status',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a booking status';
                  }
                  return null;
                },
              ),
              // --- END NEW ---
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
                icon: Icon(isEdit ? Icons.save : Icons.check, color: Colors.white),
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