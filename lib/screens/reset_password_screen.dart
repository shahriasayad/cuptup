import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/hive_service.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  void handleReset() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }
    if (password.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }
    if (password != confirm) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    // Simulate API call to reset password (commented for now)
    // final response = await http.post(...);

    // Local update for now
    HiveService.userBox.put('password', password);
    Get.snackbar('Success', 'Password reset successfully! Please login.');
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Set your new password:"),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Reset Password'),
                onPressed: handleReset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
