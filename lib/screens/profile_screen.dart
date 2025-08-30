import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cuptup/data/api_service.dart';
import 'package:cuptup/data/hive_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isEditingProfile = false;
  bool _isChangingPassword = false;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getUserProfile();

      if (response['success'] == true && response['data'] != null) {
        final user = response['data']['user'];
        setState(() {
          _userProfile = user;
          _nameController.text = user['name'] ?? '';
          _emailController.text = user['email'] ?? '';
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (response['success'] == true) {
        Get.snackbar('Success', 'Profile updated successfully');
        setState(() => _isEditingProfile = false);
        _loadUserProfile();
      } else {
        Get.snackbar(
            'Error', response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all password fields');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      Get.snackbar('Error', 'New passwords do not match');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (response['success'] == true) {
        Get.snackbar('Success', 'Password changed successfully');
        setState(() => _isChangingPassword = false);
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        Get.snackbar(
            'Error', response['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to change password');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.logout();

      // Clear local storage regardless of API response
      await HiveService.userBox.clear();
      HiveService.setLoggedIn(false);

      Get.snackbar('Success', 'Logged out successfully');
      Get.offAllNamed('/login');
    } catch (e) {
      // Even if API call fails, clear local storage and redirect
      await HiveService.userBox.clear();
      HiveService.setLoggedIn(false);
      Get.offAllNamed('/login');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Profile Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Profile Information',
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                IconButton(
                                  icon: Icon(_isEditingProfile
                                      ? Icons.close
                                      : Icons.edit),
                                  onPressed: () => setState(() =>
                                      _isEditingProfile = !_isEditingProfile),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditingProfile,
                              validator: (v) =>
                                  v!.isEmpty ? 'Name is required' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              enabled: _isEditingProfile,
                              validator: (v) {
                                if (v!.isEmpty) return 'Email is required';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(v)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            if (_isEditingProfile) ...[
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _updateProfile,
                                child: Text('Update Profile'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Change Password Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Change Password',
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                IconButton(
                                  icon: Icon(_isChangingPassword
                                      ? Icons.close
                                      : Icons.lock),
                                  onPressed: () => setState(() =>
                                      _isChangingPassword =
                                          !_isChangingPassword),
                                ),
                              ],
                            ),
                            if (_isChangingPassword) ...[
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _currentPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Current Password',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _newPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  labelText: 'Confirm New Password',
                                  border: OutlineInputBorder(),
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _changePassword,
                                child: Text('Change Password'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // User Info Display
                    if (_userProfile != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Account Details',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              SizedBox(height: 16),
                              Text('User ID: ${_userProfile!['id']}'),
                              Text('Role: ${HiveService.userBox.get('role')}'),
                              if (_userProfile!['created_at'] != null)
                                Text(
                                    'Member since: ${_userProfile!['created_at']}'),
                            ],
                          ),
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
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
