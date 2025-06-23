import 'package:flutter/material.dart';

import 'package:Project_Kururin_Exhibition/databaseServices/eventSphere_db.dart';

import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';

import 'package:Project_Kururin_Exhibition/models/admin.dart';

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
        title: const Text('EventSphere'),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFFEFEFA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome, ${widget.admin.name}!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            adminTable(context),
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
      floatingActionButton: addAdminButton(context),
    );
  }
}

Widget addAdminButton(BuildContext context) {
  return FloatingActionButton(
    onPressed: () async {
      final demoAdmin = Admin(
        name: 'Demo Admin 1',
        email: 'demo@admin.com',
        password: 'Admin@123',
        id: null, // In production, hash this!
      );
      try {
        final db = EventSphereDB.instance;
        final insertedId = await db.insertAdmin(demoAdmin);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demo Admin inserted with ID: $insertedId')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to insert admin: $e')));
      }
    },
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Colors.white,
    tooltip: 'Add New Admin',
    child: const Icon(Icons.add),
  );
}

Widget adminTable(BuildContext context) {
  return FutureBuilder<List<Admin>>(
    future: EventSphereDB.instance.getAllAdmins(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text('No admins found.');
      } else {
        final admins = snapshot.data!;
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
                label: SizedBox(width: 24), // For trailing icon
              ),
            ],
            rows:
                admins
                    .map(
                      (admin) => DataRow(
                        cells: [
                          DataCell(Text(admin.id?.toString() ?? '')),
                          DataCell(Text(admin.name)),
                          DataCell(Text(admin.email)),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () async {
                                if (admin.id != null) {
                                  await EventSphereDB.instance.deleteAdmin(
                                    admin.id!,
                                  );
                                  // Refresh the table after deletion
                                  (context as Element).markNeedsBuild();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Admin deleted')),
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
