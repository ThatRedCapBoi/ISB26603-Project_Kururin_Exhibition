import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/databaseServices/eventSphere_db.dart';
// import 'package:Project_Kururin_Exhibition/routes/app_routes.dart';

import 'package:Project_Kururin_Exhibition/pages/user/userProfile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //validation controllers
  final emailCtrl = TextEditingController();
  final pwCtrl = TextEditingController();

  bool isVisible = false;
  void _login() async {
    final email = emailCtrl.text.trim();
    final pw = pwCtrl.text;
    final u = await EventSphereDB.instance.getUserByEmail(email);
    if (u != null && u.password == pw) {
      Navigator.pushReplacementNamed(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(),
        ).settings.name!,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid login')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Login')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: emailCtrl,
            obscureText: isVisible,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: pwCtrl,
            obscureText: !isVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _login, child: const Text('Login')),
          TextButton(
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ),
            child: const Text('Register / Update Profile'),
          ),
        ],
      ),
    ),
  );
}
