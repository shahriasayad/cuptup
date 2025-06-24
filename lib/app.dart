import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'data/hive_service.dart';
import 'routes.dart';
import 'controllers/theme_controller.dart';

class CupTupApp extends StatelessWidget {
  const CupTupApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put(ThemeController());

    String initialRoute;
    if (HiveService.isLoggedIn()) {
      final role = HiveService.getUserRole();
      if (role == 'owner') {
        initialRoute = '/owner_dashboard';
      } else if (role == 'employee') {
        initialRoute = '/employee_dashboard';
      } else {
        initialRoute = '/login';
      }
    } else {
      initialRoute = '/login';
    }

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeController.themeMode.value,
          getPages: appRoutes,
          initialRoute: initialRoute,
        ));
  }
}
