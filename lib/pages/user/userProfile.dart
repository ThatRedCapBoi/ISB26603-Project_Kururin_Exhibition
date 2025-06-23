import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/databaseServices/eventSphere_db.dart';

import 'package:Project_Kururin_Exhibition/pages/login.dart';

import 'package:Project_Kururin_Exhibition/pages/user/userNavigation.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _form = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final pwCtrl = TextEditingController();

  int _selectedIndex = 2;

  void _save() async {
    if (_form.currentState!.validate()) {
      final u = User(
        id: widget.user.id,
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        password: pwCtrl.text,
      );
      await EventSphereDB.instance.updateUser(u);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Updated')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Profile'),
      automaticallyImplyLeading: false,
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _form,
        child: ListView(
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v!.isEmpty ? 'Enter name' : null,
            ),
            TextFormField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => v!.isEmpty ? 'Enter email' : null,
            ),
            TextFormField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (v) => v!.isEmpty ? 'Enter phone' : null,
            ),
            TextFormField(
              controller: pwCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        onUserDestinationSelected(context, index, widget.user);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.book_online), label: 'Booking'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    ),
  );
}
