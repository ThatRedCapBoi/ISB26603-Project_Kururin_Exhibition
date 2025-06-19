import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/databaseServices/eventSphere_db.dart';
// import 'package:Project_Kururin_Exhibition/routes/app_routes.dart';

import 'package:Project_Kururin_Exhibition/pages/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _form = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final pwCtrl = TextEditingController();
  User? _user;

  void _save() async {
    if (_form.currentState!.validate()) {
      final u = User(
        id: _user?.id,
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        password: pwCtrl.text,
      );
      if (_user == null) {
        await EventSphereDB.instance.insertUser(u);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registered')));
      } else {
        await EventSphereDB.instance.updateUser(u);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Updated')));
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
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
  );
}
