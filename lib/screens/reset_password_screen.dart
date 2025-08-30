import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cuptup/data/api_service.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_tokenController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    if (_passwordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters long');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.resetPassword(
        token: _tokenController.text.trim(),
        newPassword: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (response['success'] ?? false) {
        Get.snackbar(
          'Success',
          'Password reset successfully! Please login with your new password.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          'Error',
          response['message'] ??
              'Failed to reset password. Please check your token and try again.',
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
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Enter the reset token from your email and your new password.\n\nFor testing: Use "test123" as the token.'),
            SizedBox(height: 20),
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(labelText: 'Reset Token'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Reset Password'),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
