import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart' as my_models; // Alias to avoid conflict with FirebaseAuth.User
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart'; // Assuming this provides onAdminDestinationSelected

class AdminDashboard extends StatefulWidget {
  final Admin admin;

  const AdminDashboard({super.key, required this.admin});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 1;

  // Helper function to show a SnackBar message
  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Stream to listen for real-time updates from the 'users' collection.
  Stream<List<my_models.User>> _usersStream() {
    return FirebaseFirestore.instance.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => my_models.User.fromFirestore(doc))
              .toList(),
        );
  }

  // Function to delete a user directly via Firestore
  Future<void> _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      _showSnackBar('User deleted successfully.');
    } catch (e) {
      _showSnackBar('Failed to delete user: $e', backgroundColor: Colors.red);
      print('Error deleting user: $e'); // Log the error for debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFEFEFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'User Management Page',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Use StreamBuilder for real-time updates of user list
            Expanded(
              child: StreamBuilder<List<my_models.User>>(
                stream: _usersStream(), // Use a stream to listen for real-time changes
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  } else {
                    final users = snapshot.data!;
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // Allow horizontal scrolling for wide tables
                        child: DataTable(
                          columnSpacing: 8.0, // Reduce spacing between columns
                          columns: const [
                            DataColumn(
                              label: Expanded(
                                child: Text('ID', overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text('Name', overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text('Email', overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text('Phone', overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(width: 24), // For trailing icon
                            ),
                          ],
                          rows: users
                              .map(
                                (user) => DataRow(
                                  cells: [
                                    DataCell(Text(user.id?.toString() ?? 'N/A')), // Display Firestore document ID
                                    DataCell(
                                      Text(user.name, overflow: TextOverflow.ellipsis),
                                    ),
                                    DataCell(
                                      Text(user.email, overflow: TextOverflow.ellipsis),
                                    ),
                                    DataCell(
                                      Text(user.phone, overflow: TextOverflow.ellipsis),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Delete',
                                        onPressed: () {
                                          if (user.id != null) {
                                            _deleteUser(user.id!); // Call the direct delete function
                                          } else {
                                            _showSnackBar('User ID is missing.', backgroundColor: Colors.orange);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
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
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_online),
            label: 'Booking',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
