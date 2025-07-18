import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart'
    as my_models; // Alias to avoid conflict with FirebaseAuth.User
import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart'; // Assuming this provides onAdminDestinationSelected
import 'package:Project_Kururin_Exhibition/pages/admin/adminManageUser.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserManagementPage extends StatefulWidget {
  final Admin admin;

  const AdminUserManagementPage({super.key, required this.admin});

  @override
  State<AdminUserManagementPage> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagementPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Ensure children align left
          children: [
            Text(
              'User Management Page',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.left,
            ),
            Expanded(
              child: UserTable(
                admin: widget.admin,
              ), // Call the usertable function
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
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class UserTable extends StatefulWidget {
  final Admin admin;
  const UserTable({super.key, required this.admin});

  @override
  State<UserTable> createState() => _userTableState();
}

class _userTableState extends State<UserTable> {
  // Helper function to show a SnackBar message
  void _showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  // Stream to listen for real-time updates from the 'users' collection.
  Stream<List<my_models.User>> _usersStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
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
    return StreamBuilder<List<my_models.User>>(
      stream: _usersStream(),
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
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 8.0,
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
                  DataColumn(label: SizedBox(width: 24)),
                  DataColumn(label: SizedBox(width: 24)),
                ],
                rows:
                    users
                        .map(
                          (user) => DataRow(
                            cells: [
                              DataCell(
                                SizedBox(
                                  width: 120, // Increased width for more space
                                  child: Text(
                                    user.id.toString(),
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    user.name,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.email,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.phone,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Edit',
                                  onPressed: () {
                                    if (user.id.toString().isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => AdminManageUser(
                                                admin: widget.admin,
                                                user: user,
                                              ),
                                        ),
                                      );
                                    } else {
                                      _showSnackBar(
                                        'User ID is missing.',
                                        backgroundColor: Colors.orange,
                                      );
                                    }
                                  },
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    if (user.id.toString().isNotEmpty) {
                                      _deleteUser(user.id);
                                    } else {
                                      _showSnackBar(
                                        'User ID is missing.',
                                        backgroundColor: Colors.orange,
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
            ),
          );
        }
      },
    );
  }
}

Widget usertable(BuildContext context, {required Admin admin}) {
  return UserTable(admin: admin);
}
