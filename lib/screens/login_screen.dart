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

    // Check registration
    final isRegistered = HiveService.userBox.get('registered') ?? false;
    if (!isRegistered) {
      Get.snackbar('Not Registered', 'Please register first.');
      Get.offAllNamed('/register');
      return;
    }

    // Get saved user data from Hive
    final savedUsername = HiveService.userBox.get('username');
    final savedEmail = HiveService.userBox.get('email');
    final savedPassword = HiveService.userBox.get('password');
    final role = HiveService.userBox.get('role');

    // Validate credentials with saved registration
    if (username == savedUsername &&
        email == savedEmail &&
        password == savedPassword) {
      HiveService.setLoggedIn(true);
      // Optionally update user info (not needed, but kept for compatibility)
      HiveService.userBox.put('username', username);
      HiveService.userBox.put('email', email);

      if (role == 'owner') {
        Get.offAllNamed('/owner_dashboard');
      } else {
        Get.offAllNamed('/employee_dashboard');
      }
    } else {
      Get.snackbar('Error', 'Invalid credentials');
      return;
    }
  }

  void goToForgotPassword() {
    Get.toNamed('/forgot_password');
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
              ElevatedButton(
                child: Text('LOGIN'),
                onPressed: handleLogin,
              ),
              TextButton(
                onPressed: goToForgotPassword,
                child: Text("Forgot Password?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
