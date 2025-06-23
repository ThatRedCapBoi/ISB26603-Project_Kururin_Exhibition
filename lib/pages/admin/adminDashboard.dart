import 'package:Project_Kururin_Exhibition/databaseServices/eventSphere_db.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart' as my_models;

import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';

class AdminDashboard extends StatefulWidget {
  final Admin admin;

  const AdminDashboard({super.key, required this.admin});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 1;

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
            userManagementTable(context),
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

Widget userManagementTable(BuildContext context) {
  return FutureBuilder<List<my_models.User>>(
    future: EventSphereDB.instance.getAllUsers(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text('No users found.');
      } else {
        final users = snapshot.data!;
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
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
            rows:
                users
                    .map(
                      (user) => DataRow(
                        cells: [
                          DataCell(Text(user.id?.toString() ?? '')),
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
                              onPressed: () async {
                                if (user.id != null) {
                                  await EventSphereDB.instance.deleteUser(
                                    user.id!,
                                  );
                                  (context as Element).markNeedsBuild();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('User deleted'),
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
      }
    },
  );
}
