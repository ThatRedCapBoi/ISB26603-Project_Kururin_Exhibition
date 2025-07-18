import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/booth.dart'; // Ensure this is updated to BoothPackage
import 'package:Project_Kururin_Exhibition/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class HomePage extends StatelessWidget {
  const HomePage({super.key}); // Added const constructor for consistency

  @override
  Widget build(BuildContext context) {
    // No longer using static getBoothPackages() here
    // final List<boothPackage> boothPackages = boothPackage.getBoothPackages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EventSphere'), // Added const
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Text(
                  // Added const
                  '🎉Welcome to Kururin Exhibition🎉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10), // Added const
                const Text(
                  // Added const
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
          const SizedBox(height: 16), // Added const
          // Fetch booth packages from Firestore using StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('boothPackages')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No booth packages available.'),
                  );
                }

                final boothPackages =
                    snapshot.data!.docs.map((doc) {
                      return BoothPackage.fromFirestore(
                        doc,
                      ); // Use the updated fromFirestore factory
                    }).toList();

                return ListView.builder(
                  itemCount: boothPackages.length,
                  itemBuilder: (context, index) {
                    final booth = boothPackages[index];
                    return BoothCard(
                      context,
                      booth,
                    ); // Reusing the BoothCard widget
                  },
                );
              },
            ),
          ),
        ],
      ),
      // No bottom navigation bar for public homepage
    );
  }
}

Widget BoothCard(BuildContext context, BoothPackage booth) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child:
                booth.boothImage.startsWith('http')
                    ? Image.network(booth.boothImage, fit: BoxFit.cover)
                    : Image.asset(booth.boothImage, fit: BoxFit.cover),
          ),
        ),
        ListTile(
          leading: Text(
            '\RM${booth.boothPrice.toString()}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              // backgroundColor: Theme.of(context).colorScheme.primary,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
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
              builder:
                  (_) => AlertDialog(
                    title: Text(booth.boothName),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RM${booth.boothPrice}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Decription\n• ${booth.boothDescription}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Capacity\n• ${booth.boothCapacity}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
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
