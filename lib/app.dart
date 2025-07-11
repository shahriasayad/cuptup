import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'data/hive_service.dart';
import 'routes.dart';
import 'controllers/theme_controller.dart';

class CupTupApp extends StatelessWidget {
  const CupTupApp({super.key});

  Future<String> getInitialRoute() async {
    await HiveService.init(); // Ensure Hive is ready
    final isRegistered = HiveService.userBox.get('registered') ?? false;
    final isLoggedIn = HiveService.userBox.get('loggedIn') ?? false;

    if (!isRegistered) {
      return '/register';
    } else if (!isLoggedIn) {
      return '/login';
    } else {
      final role = HiveService.userBox.get('role');
      if (role == 'owner') {
        return '/owner_dashboard';
      } else if (role == 'employee') {
        return '/employee_dashboard';
      } else {
        return '/login';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    return FutureBuilder<String>(
      future: getInitialRoute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Obx(() => GetMaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.light(),
              darkTheme: ThemeData.dark(),
              themeMode: themeController.themeMode.value,
              getPages: appRoutes,
              initialRoute: snapshot.data!,
            ));
      },
    );
  }
}
