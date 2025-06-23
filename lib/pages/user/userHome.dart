// lib/pages/user/userHome.dart
import 'package:Project_Kururin_Exhibition/pages/user/userBookingForm.dart';
import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/booth.dart'; // Ensure this is updated to BoothPackage
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userNavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class UserHomePage extends StatelessWidget {
  final User user;

  const UserHomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // No longer using static getBoothPackages() here
    // final List<boothPackage> boothPackages = boothPackage.getBoothPackages();
    int selectedIndex = 0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('EventSphere'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              children: [
                Text(
                  'Welcome ${user.name}!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your one-stop platform for seamless exhibition booth reservations. '
                  'Discover flexible packages, book online, and manage your events with ease.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Fetch booth packages from Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('boothPackages').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No booth packages available.'));
                }

                final boothPackages = snapshot.data!.docs.map((doc) {
                  return BoothPackage.fromFirestore(doc); // Use the new fromFirestore factory
                }).toList();

                return ListView.builder(
                  itemCount: boothPackages.length,
                  itemBuilder: (context, index) {
                    final booth = boothPackages[index];
                    return BoothCard(context, booth); // Pass the fetched booth
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          onUserDestinationSelected(context, index, user);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
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

// Renamed to BoothCard for consistency and moved outside the class as it's a separate widget
Widget BoothCard(BuildContext context, BoothPackage booth) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Image.asset(booth.boothImage, fit: BoxFit.cover), // Assuming boothImage is a local asset path
          ),
        ),
        ListTile(
          title: Text(
            booth.boothName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(
            booth.boothDescription,
            style: const TextStyle(height: 1.4),
          ),
          trailing: const Icon(Icons.info_outline),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(booth.boothName),
                content: Text(booth.boothDescription),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
  );
}