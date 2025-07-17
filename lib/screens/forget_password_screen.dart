import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/hive_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  void handleSubmit() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email');
      return;
    }

    // Simulate API call here (commented for now)
    // final response = await http.post(...);

    // Local check for now
    final savedEmail = HiveService.userBox.get('email');
    if (email == savedEmail) {
      // API would send an email/reset token here
      // For now, navigate directly to reset password
      Get.toNamed('/reset_password', arguments: {'email': email});
    } else {
      Get.snackbar('Error', 'Email not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Enter your registered email to reset your password:"),
              SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Submit'),
                onPressed: handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
