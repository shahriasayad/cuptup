import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cuptup/data/api_service.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _usernameController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _selectedRole = 'owner';
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _passwordVisibleConfirm = false;
  bool _confirmPasswordVisible = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      print('Starting registration process...');
      print('Username: ${_usernameController.text.trim()}');
      print('Email: ${_emailController.text.trim()}');
      print('Role: $_selectedRole');

      final response = await _apiService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      setState(() => _isLoading = false);

      print('Registration response: $response');

      if (response['success'] ?? false) {
        Get.snackbar(
          'Success',
          'Registration successful! Please login.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed('/login');
      } else {
        String errorMessage =
            response['message'] ?? 'Registration failed. Please try again.';

        // Show detailed error for debugging
        if (errorMessage.contains('Network error')) {
          errorMessage += '\n\nDEBUG INFO:';
          errorMessage += '\n• Mock API is currently enabled for testing';
          errorMessage += '\n• Check API Test screen for detailed diagnostics';
          errorMessage += '\n• You can still test the app functionality';
        }

        Get.snackbar(
          'Registration Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 8),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Registration exception: $e');

      Get.snackbar(
        'Error',
        'Network error occurred. Mock API is enabled for testing.\n\nOriginal error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 10),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Username is required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.isEmpty) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(v)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // TextFormField(
              //   controller: _passwordController,
              //   decoration: InputDecoration(
              //     labelText: 'Password',
              //     suffixIcon: IconButton(
              //       icon: Icon(_passwordVisible
              //           ? Icons.visibility_off
              //           : Icons.visibility),
              //       onPressed: () {
              //         setState(() {
              //           _passwordVisible = !_passwordVisible;
              //         });
              //       },
              //     ),
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.lock),
              //   ),
              //   obscureText: !_passwordVisible,
              //   validator: (v) {
              //     if (v!.isEmpty) return 'Password is required';
              //     if (v.length < 6)
              //       return 'Password must be at least 6 characters';
              //     return null;
              //   },
              // ),
              // SizedBox(height: 16),
              // TextFormField(
              //   controller: _confirmController,
              //   decoration: InputDecoration(
              //     labelText: 'Confirm Password',
              //     suffixIcon: IconButton(
              //       icon: Icon(_passwordVisible
              //           ? Icons.visibility_off
              //           : Icons.visibility),
              //       onPressed: () {
              //         setState(() {
              //           _passwordVisible = !_passwordVisible;
              //         });
              //       },
              //     ),
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.lock_outline),
              //   ),
              //   obscureText: true,
              //   validator: (v) {
              //     if (v!.isEmpty) return 'Please confirm your password';
              //     if (v != _passwordController.text)
              //       return 'Passwords do not match';
              //     return null;
              //   },
              // ),

              // add two separate state variables

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: !_passwordVisible, // works correctly
                validator: (v) {
                  if (v!.isEmpty) return 'Password is required';
                  if (v.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: _confirmController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(_confirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: !_confirmPasswordVisible, // FIXED: was hardcoded
                validator: (v) {
                  if (v!.isEmpty) return 'Please confirm your password';
                  if (v != _passwordController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),

              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: ['owner', 'employee']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRole = v!),
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Creating Account...'),
                          ],
                        )
                      : Text(
                          'Create Account',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Get.toNamed('/login'),
                child: Text(
                  'Already have an account? Login here',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Get.toNamed('/api-test'),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange[100],
                ),
                child: Text(
                  '🔧 API Connection Issues? Test Here',
                  style: TextStyle(
                      color: Colors.orange[800], fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
