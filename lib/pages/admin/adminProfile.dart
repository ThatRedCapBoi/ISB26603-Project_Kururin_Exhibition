import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProfilePage extends StatefulWidget {
  final Admin admin;

  const AdminProfilePage({super.key, required this.admin});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  int _selectedIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere Admin Dashboard'),
        automaticallyImplyLeading: false,
      ),
      // backgroundColor: const Color(0xFFFEFEFA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            Expanded(child: adminTable(context)),
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

class _AdminTable extends StatefulWidget {
  @override
  State<_AdminTable> createState() => _AdminTableState();
}

class _AdminTableState extends State<_AdminTable> {
  // Method to delete an admin from Firestore
  // Future<void> _deleteAdmin(String adminId) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('administrators')
  //         .doc(adminId)
  //         .delete();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Admin deleted successfully!')),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to delete admin: ${e.toString()}')),
  //     );
  //     print('Error deleting admin: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('administrators').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No administrators found.'));
        }

        final admins =
            snapshot.data!.docs.map((doc) {
              return Admin.fromFirestore(
                doc,
              ); // Use the updated fromFirestore factory
            }).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 8.0,
            columns: const [
              DataColumn(
                label: Text('ID (UID)'),
              ), // Changed to UID for Firebase
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              // DataColumn(label: Text('Actions')), // For delete button
            ],
            rows:
                admins
                    .map(
                      (admin) => DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 90,
                              child: Text(
                                admin.id,
                                softWrap: true,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ), // Display UID
                          DataCell(
                            SizedBox(
                              width: 80,
                              child: Text(admin.name, softWrap: true),
                            ),
                          ),
                          DataCell(Text(admin.email)),
                          // DataCell(
                          //   IconButton(
                          //     icon: const Icon(Icons.delete, color: Colors.red),
                          //     tooltip: 'Delete',
                          //     onPressed: () {
                          //       if (admin.id.isNotEmpty) {
                          //         _deleteAdmin(admin.id);
                          //       } else {
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //           const SnackBar(
                          //             content: Text('Admin ID is missing.'),
                          //           ),
                          //         );
                          //       }
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }
}

Widget adminTable(BuildContext context) {
  return _AdminTable(); // Use the new StatefulWidget
}
