import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  var themeMode = ThemeMode.system.obs;

  void toggleTheme() {
    themeMode.value =
        themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
