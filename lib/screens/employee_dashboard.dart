import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/hive_service.dart';
import '../widgets/drawer.dart';
import '../widgets/dashboard_widget.dart';

class EmployeeDashboard extends StatefulWidget {
  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  void initState() {
    super.initState();
    if (HiveService.getUserRole() != 'employee') {
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
        title: Text('Employee Dashboard'),
      ),
      drawer: CupTupDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: Text('View Menu'),
                trailing: Icon(Icons.chevron_right),
                onTap: () => Get.toNamed('/menu'),
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
