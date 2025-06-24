import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/pages/homepage.dart';

import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class AdminHomePage extends StatefulWidget {
  final Admin admin;

  const AdminHomePage({super.key, required this.admin});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere Admin Dashboard'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFEFEFA),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 16),
            Text(
              'Welcome, ${widget.admin.name}!',
              style: TextStyle(
                fontSize: 24, // Increased font size for welcome message
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Updated adminTable to use Firestore
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
          // Call the function from adminNavigation.dart
          onAdminDestinationSelected(
            context,
            index,
            widget.admin,
          ); // Changed function name
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

// Renamed from adminTable to _AdminTable and made it a StatefulWidget to manage its own state (e.g., refresh)
class _AdminTable extends StatefulWidget {
  const _AdminTable({super.key});

  @override
  State<_AdminTable> createState() => _AdminTableState();
}

class _AdminTableState extends State<_AdminTable> {
  // Method to delete an admin from Firestore
  Future<void> _deleteAdmin(String adminId) async {
    try {
      await FirebaseFirestore.instance
          .collection('administrators')
          .doc(adminId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete admin: ${e.toString()}')),
      );
      print('Error deleting admin: $e');
    }
  }

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
              DataColumn(label: Text('Actions')), // For delete button
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
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () {
                                if (admin.id.isNotEmpty) {
                                  _deleteAdmin(admin.id);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Admin ID is missing.'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
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

// This is the function called in AdminHomePage, you might want to adjust its signature.
Widget adminTable(BuildContext context) {
  return const _AdminTable(); // Use the new StatefulWidget
}
