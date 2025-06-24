import 'package:flutter/material.dart';
import '../data/hive_service.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final username = HiveService.userBox.get('username') ?? '';
    final email = HiveService.userBox.get('email') ?? '';
    return Scaffold(
      appBar: AppBar(title: Text('User Info')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Username: $username', style: TextStyle(fontSize: 18)),
            SizedBox(height: 12),
            Text('Email: $email', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}