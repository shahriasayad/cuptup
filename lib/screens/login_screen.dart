import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cuptup/data/api_service.dart';
import 'package:cuptup/data/hive_service.dart';
import 'package:cuptup/widgets/responsive_helper.dart';
import 'package:flutter/foundation.dart';

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  String _selectedRole = 'owner';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter credentials');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (response['success'] == true && response['data'] != null) {
        final token = response['data']['token'];
        final user = response['data']['user'];
        final role = user['role'] ?? _selectedRole;

        if (role != _selectedRole) {
          Get.snackbar(
              'Error', 'The selected role does not match your account.');
          return;
        }

        await HiveService.userBox.put('token', token);
        await HiveService.userBox.put('role', role);
        await HiveService.userBox.put('user', user);
        await HiveService.userBox.put('loggedIn', true);
        await HiveService.userBox.put('registered', true);
        HiveService.setLoggedIn(true);
        HiveService.setUserRole(role);

        Get.snackbar('Success', 'Login successful!');

        if (role == 'owner') {
          Get.offAllNamed('/owner_dashboard');
        } else {
          Get.offAllNamed('/employee_dashboard');
        }
      } else if (response['token'] != null) {
        final token = response['token'];
        final role = response['role'];

        if (role != _selectedRole) {
          Get.snackbar(
              'Error', 'The selected role does not match your account.');
          return;
        }

        await HiveService.userBox.put('token', token);
        await HiveService.userBox.put('role', role);
        await HiveService.userBox.put('loggedIn', true);
        await HiveService.userBox.put('registered', true);
        HiveService.setLoggedIn(true);
        HiveService.setUserRole(role);

        Get.snackbar('Success', 'Login successful!');

        if (role == 'owner') {
          Get.offAllNamed('/owner_dashboard');
        } else {
          Get.offAllNamed('/employee_dashboard');
        }
      } else {
        Get.snackbar(
            'Error',
            response['message'] ??
                'Login failed. Please check your credentials.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error',
          'Network error. Please check your connection and try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.isWeb() ? 400 : double.infinity,
          ),
          padding:
              EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                cursorColor: Colors.white,
                // decoration: InputDecoration(labelText: 'Email'),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.teal,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                cursorColor: Colors.white,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    color: Colors.teal,
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.teal,
                  ),
                ),
                obscureText: _obscurePassword,
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
                  labelText: 'Login As',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.teal,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: 220,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.teal)),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Login',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),

              // TextButton(
              //   onPressed: () => Get.toNamed('/forgot-password'),
              //   child: Text('Forgot Password?'),
              // ),
              TextButton(
                onPressed: () => Get.toNamed('/register'),
                child: Text(
                  'Create New Account',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
