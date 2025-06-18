import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final pwCtrl = TextEditingController();

  void _login() async {
    final email = emailCtrl.text.trim();
    final pw = pwCtrl.text;
    final u = await DatabaseHelper.instance.getUserByEmail(email);
    if (u != null && u.password == pw) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid login')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: pwCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
                child: const Text('Register / Update Profile'),
              ),
            ],
          ),
        ),
      );
}