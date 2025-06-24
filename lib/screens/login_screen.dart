import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/hive_service.dart';

class LogInScreen extends StatefulWidget {
  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void handleLogin() {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'All fields are required');
      return;
    }

    String? role;
    if (email == 'owner@gmail.com' && password == 'ownerpass') {
      role = 'owner';
    } else if (email == 'employe@gmail.com' && password == 'employeepass') {
      role = 'employee';
    } else {
      Get.snackbar('Error', 'Invalid credentials');
      return;
    }

    HiveService.setLoggedIn(true);
    HiveService.userBox.put('username', username);
    HiveService.userBox.put('email', email);
    HiveService.setUserRole(role);

    if (role == 'owner') {
      Get.offAllNamed('/owner_dashboard');
    } else {
      Get.offAllNamed('/employee_dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(child: Text('LOGIN'), onPressed: handleLogin),
            ],
          ),
        ),
      ),
    );
  }
}
