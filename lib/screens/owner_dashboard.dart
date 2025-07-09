import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/hive_service.dart';
import '../widgets/drawer.dart';
import '../widgets/dashboard_widget.dart';

class OwnerDashboard extends StatefulWidget {
  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  @override
  void initState() {
    super.initState();
    if (HiveService.getUserRole() != 'owner') {
      Get.snackbar('Error', 'Unauthorized');
      Get.offAllNamed('/login');
    }
  }

  void logout() async {
    final confirm =
        await Get.dialog(AlertDialog(title: Text('Logout?'), actions: [
      TextButton(
          onPressed: () => Get.back(result: false), child: Text('Cancel')),
      TextButton(
          onPressed: () => Get.back(result: true), child: Text('Logout')),
    ]));
    if (confirm == true) {
      HiveService.setLoggedIn(false);
      HiveService.clearUserRole();
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner Dashboard'),
      ),
      drawer: CupTupDrawer(), // Drawer is always on left
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              color: Colors.green[50],
              child: ListTile(
                title: Text(
                  'Manage Menu Items',
                  style: TextStyle(color: Colors.black),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Colors.black,
                ),
                onTap: () => Get.toNamed('/item_management'),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: DashboardWidget(),
            )
          ],
        ),
      ),
    );
  }
}
