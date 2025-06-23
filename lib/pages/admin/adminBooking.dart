import 'package:Project_Kururin_Exhibition/databaseServices/eventSphere_db.dart';
import 'package:flutter/material.dart';

import 'package:Project_Kururin_Exhibition/pages/admin/adminNavigation.dart';
import 'package:Project_Kururin_Exhibition/models/booth_book.dart';

import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userBookingForm.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';

class AdminBookingPage extends StatefulWidget {
  final Admin admin;

  const AdminBookingPage({super.key, required this.admin});

  @override
  State<AdminBookingPage> createState() => _AdminBookingPageState();
}

class _AdminBookingPageState extends State<AdminBookingPage> {
  int _selectedIndex = 2;

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
            SizedBox(height: 16),
            Text(
              'Booth Booking Management ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(child: boothBookingCardList(context)),
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

// Widget boothBookingTable(BuildContext context) {
//   return FutureBuilder<List<Booking>>(
//     future: EventSphereDB.instance.getAllBookings(),
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const CircularProgressIndicator();
//       } else if (snapshot.hasError) {
//         return Text('Error: ${snapshot.error}');
//       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//         return const Text('No booking found.');
//       } else {
//         final bookings = snapshot.data!;
//         return SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               columnSpacing: 8.0,
//               columns: const [
//                 DataColumn(
//                   label: Expanded(
//                     child: Text('Booking ID', overflow: TextOverflow.ellipsis),
//                   ),
//                 ),
//                 DataColumn(
//                   label: Expanded(
//                     child: Text('User Email', overflow: TextOverflow.ellipsis),
//                   ),
//                 ),
//                 DataColumn(
//                   label: Expanded(
//                     child: Text('Booth Type', overflow: TextOverflow.ellipsis),
//                   ),
//                 ),
//                 DataColumn(
//                   label: Expanded(
//                     child: Text('Additional Items', overflow: TextOverflow.ellipsis),
//                   ),
//                 ),
//                 DataColumn(
//                   label: Expanded(
//                     child: Text('Date', overflow: TextOverflow.ellipsis),
//                   ),
//                 ),
//                 DataColumn(
//                   label: SizedBox(width: 24), // For trailing icon
//                 ),
//               ],
//               rows: bookings
//                   .map(
//                     (booking) => DataRow(
//                       cells: [
//                         DataCell(Text(booking.bookid?.toString() ?? '', overflow: TextOverflow.ellipsis)),
//                         DataCell(Text(booking.userEmail ?? '', overflow: TextOverflow.ellipsis)),
//                         DataCell(Text(booking.boothType ?? '', overflow: TextOverflow.ellipsis)),
//                         DataCell(Text(booking.additionalItems ?? '', overflow: TextOverflow.ellipsis)),
//                         DataCell(Text(booking.date ?? '', overflow: TextOverflow.ellipsis)),
//                         DataCell(
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             tooltip: 'Delete',
//                             onPressed: () async {
//                               if (booking.bookid != null) {
//                                 await EventSphereDB.instance.deleteBooking(
//                                   booking.bookid!,
//                                 );
//                                 (context as Element).markNeedsBuild();
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text('Booking deleted'),
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         );
//       }
//     },
//   );
// }

Widget boothBookingCardList(BuildContext context) {
  return FutureBuilder<List<Booking>>(
    future: EventSphereDB.instance.getAllBookings(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No bookings found.'));
      } else {
        final bookings = snapshot.data!;
        return ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                title: Text("Booth: ${booking.boothType}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("User: ${booking.userEmail ?? ''}"),
                    Text("Date: ${booking.date ?? ''}"),
                    Text(
                      "Items: ${(booking.additionalItems is List) ? (booking.additionalItems as List).join(', ') : booking.additionalItems?.toString() ?? ''}",
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    // You need a User object for BookingFormPage.
                    // If you don't have user info, you can pass a dummy User or fetch by email.
                    // Here, we fetch by email:
                    User? user;
                    if (booking.userEmail != null) {
                      user = await EventSphereDB.instance.getUserByEmail(
                        booking.userEmail!,
                      );
                    }
                    if (user != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BookingFormPage(
                                user: user!,
                                existingBooking: booking,
                              ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User not found for this booking.'),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      }
    },
  );
}
