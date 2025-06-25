import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';

import 'package:Project_Kururin_Exhibition/models/booth.dart'; // Import BoothPackage model

import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart'; // Assuming this provides onAdminDestinationSelected

class AdminManageBoothsPage extends StatefulWidget {
  final Admin admin;
  const AdminManageBoothsPage({super.key, required this.admin});

  @override
  State<AdminManageBoothsPage> createState() => _AdminManageBoothsPageState();
}

class _AdminManageBoothsPageState extends State<AdminManageBoothsPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EventSphere Admin Dashboard '),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Ensure children align left
          children: [
            Text(
              'Booths Package List',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/adminAddBooth');
            //   },
            //   child: const Text('Add New Booth'),
            // ),
            Expanded(child: boothPackageList(context)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
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

// Dialog for editing a booth
class _EditBoothDialog extends StatefulWidget {
  final BoothPackage booth;

  const _EditBoothDialog({required this.booth});

  @override
  State<_EditBoothDialog> createState() => _EditBoothDialogState();
}

class _EditBoothDialogState extends State<_EditBoothDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _boothNameController;
  late TextEditingController _boothDescriptionController;
  late TextEditingController _boothCapacityController;
  late TextEditingController _boothImageController;
  late TextEditingController _boothPriceController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _boothNameController = TextEditingController(text: widget.booth.boothName);
    _boothDescriptionController = TextEditingController(
      text: widget.booth.boothDescription,
    );
    _boothCapacityController = TextEditingController(
      text: widget.booth.boothCapacity,
    );
    _boothImageController = TextEditingController(
      text: widget.booth.boothImage,
    );
    _boothPriceController = TextEditingController(
      text: widget.booth.boothPrice.toString(),
    );
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

  Future<void> _updateBooth() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedBoothData = {
          'boothName': _boothNameController.text.trim(),
          'boothDescription': _boothDescriptionController.text.trim(),
          'boothCapacity': _boothCapacityController.text.trim(),
          'boothImage': _boothImageController.text.trim(),
          'boothPrice': int.parse(
            _boothPriceController.text.trim(),
          ), // Ensure Parse as number
        };

        await FirebaseFirestore.instance
            .collection('boothPackages')
            .doc(widget.booth.id)
            .update(updatedBoothData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booth updated successfully!')),
        );
        Navigator.pop(context); // Close the dialog
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update booth: $e')));
        print('Error updating booth: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Booth'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
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
              TextFormField(
                controller: _boothCapacityController,
                decoration: const InputDecoration(labelText: 'Capacity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter booth capacity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _boothImageController,
                decoration: const InputDecoration(labelText: 'Image URL/Path'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL or path';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _boothPriceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
              onPressed: _updateBooth,
              child: const Text('Update'),
            ),
      ],
    );
  }
}

class _addBoothCard extends StatefulWidget {
  @override
  State<_addBoothCard> createState() => _AddBoothCardState();
}

class _AddBoothCardState extends State<_addBoothCard> {
  Stream<List<BoothPackage>> _boothPackagesStream() {
    return FirebaseFirestore.instance
        .collection('boothPackages')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => BoothPackage.fromFirestore(doc))
                  .toList(),
        );
  }

  // Function to delete a booth
  Future<void> _deleteBooth(String boothId) async {
    try {
      await FirebaseFirestore.instance
          .collection('boothPackages')
          .doc(boothId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booth deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete booth: $e')));
      print('Error deleting booth: $e');
    }
  }

  void _editBooth(BoothPackage booth) {
    showDialog(
      context: context,
      builder: (context) => _EditBoothDialog(booth: booth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BoothPackage>>(
      stream: _boothPackagesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No booths found.'));
        } else {
          final boothPackages = snapshot.data!;
          return ListView.builder(
            itemCount: boothPackages.length,
            itemBuilder: (context, index) {
              final booth = boothPackages[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading:
                      booth.boothImage.isNotEmpty
                          ? Image.network(
                            booth.boothImage,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.broken_image,
                                ), // Fallback for broken image
                          )
                          : const Icon(Icons.image_not_supported),
                  title: Text(booth.boothName),
                  subtitle: Text(
                    'Capacity: ${booth.boothCapacity}\n${booth.boothDescription}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editBooth(booth),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (booth.id != null) {
                            _deleteBooth(booth.id!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Booth ID is missing.'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

Widget boothPackageList(BuildContext context) {
  return _addBoothCard();
}
