// lib/pages/admin/adminAddBooth.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Project_Kururin_Exhibition/models/booth.dart'; // Import BoothPackage model

class AdminAddBoothPage extends StatefulWidget {
  const AdminAddBoothPage({super.key});

  @override
  State<AdminAddBoothPage> createState() => _AdminAddBoothPageState();
}

class _AdminAddBoothPageState extends State<AdminAddBoothPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _boothNameController = TextEditingController();
  final TextEditingController _boothDescriptionController =
      TextEditingController();
  final TextEditingController _boothCapacityController =
      TextEditingController();
  final TextEditingController _boothPriceController = TextEditingController();
  final TextEditingController _boothImageController = TextEditingController();

  bool _isLoading = false;

  Future<void> _addBooth() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final newBooth = BoothPackage(
          boothName: _boothNameController.text.trim(),
          boothDescription: _boothDescriptionController.text.trim(),
          boothCapacity: _boothCapacityController.text.trim(),
          boothPrice: int.tryParse(_boothPriceController.text.trim()) ?? 0,
          boothImage: _boothImageController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('boothPackages')
            .add(newBooth.toFirestore());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booth added successfully!')),
        );
        Navigator.pop(context); // Go back to the AdminBookingPage
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add booth: $e')));
        print('Error adding booth: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _boothNameController.dispose();
    _boothDescriptionController.dispose();
    _boothCapacityController.dispose();
    _boothImageController.dispose();
    _boothPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EventSphere Admin Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Add New Booth',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.left,
              ),
              TextFormField(
                controller: _boothNameController,
                decoration: const InputDecoration(labelText: 'Booth Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a booth name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _boothDescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _boothCapacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity ',
                  hintText: 'e.g. 50 people',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter booth capacity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _boothImageController,
                decoration: const InputDecoration(
                  labelText: 'Image URL/Path',
                  hintText: 'e.g URL or assets/images/booth_example.png',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL or path';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _boothPriceController,
                decoration: const InputDecoration(
                  labelText: 'Price (RM)',
                  hintText: 'Enter price in RM',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Center(
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _addBooth,
                          child: const Text('Add Booth'),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
