import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cuptup/data/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      Get.snackbar('Error', 'Please enter a valid email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.forgotPassword(
        email: _emailController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (response['success'] ?? false) {
        Get.snackbar(
          'Success',
          'A password reset link has been sent to your email.\n\nFor testing: Use token "test123" in the reset password screen.',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Error',
          response['message'] ?? 'Failed to send reset link. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Network error. Please check your connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter your email to receive a password reset link'),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendResetLink,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Send Reset Link'),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/reset-password'),
              child: Text('Have a token? Reset Password'),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
