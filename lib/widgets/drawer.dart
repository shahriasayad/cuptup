import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/hive_service.dart';

class CupTupDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final username = HiveService.userBox.get('username') ?? '';
    final email = HiveService.userBox.get('email') ?? '';
    final role = HiveService.userBox.get('role') ?? '';
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('$username'),
            accountEmail: Text('$email'),
            currentAccountPicture: CircleAvatar(
              child: Text(username.isNotEmpty ? username[0] : '?'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('User'),
            onTap: () => Get.toNamed('/user'),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Sales History'),
            onTap: () => Get.toNamed('/sales_history'),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () => Get.toNamed('/about'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              final confirm = await Get.dialog(
                AlertDialog(
                  title: Text('Logout?'),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text('Cancel')),
                    TextButton(
                        onPressed: () => Get.back(result: true),
                        child: Text('Logout')),
                  ],
                ),
              );
              if (confirm == true) {
                HiveService.setLoggedIn(false);
                HiveService.clearUserRole();
                Get.offAllNamed('/login');
              }
            },
          ),
          if (role == 'owner') // Only visible for owners!
            ListTile(
              leading: Icon(Icons.delete_forever),
              title: Text('Wipe Data'),
              onTap: () async {
                final confirm = await Get.dialog(
                  AlertDialog(
                    title: Text('Wipe all data?'),
                    content: Text(
                        'This will erase all sales data and reset statistics.'),
                    actions: [
                      TextButton(
                          onPressed: () => Get.back(result: false),
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () => Get.back(result: true),
                          child: Text('Wipe')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await HiveService.salesBox.clear();
                }
              },
            ),
        ],
      ),
    );
  }
}
