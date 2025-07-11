import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'data/item_model.dart';
import 'data/hive_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ItemModelAdapter());
  await HiveService.init();
  final isRegistered = HiveService.userBox.get('registered') ?? false;
  final isLoggedIn = HiveService.userBox.get('loggedIn') ?? false;

  runApp(const CupTupApp());
}
