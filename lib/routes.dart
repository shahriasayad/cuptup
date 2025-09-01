import 'package:cuptup/screens/forget_password_screen.dart';
import 'package:cuptup/screens/registration_screen.dart';
import 'package:cuptup/screens/reset_password_screen.dart';
import 'package:cuptup/screens/profile_screen.dart';
import 'package:get/get.dart';
import 'screens/login_screen.dart';
import 'screens/owner_dashboard.dart';
import 'screens/employee_dashboard.dart';
import 'screens/item_management_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/sales_history_screen.dart';
import 'screens/transaction_details_screen.dart';
import 'screens/about_app_screen.dart';
import 'screens/user_page.dart';

final appRoutes = [
  GetPage(name: '/login', page: () => LogInScreen()),
  GetPage(name: '/owner_dashboard', page: () => OwnerDashboard()),
  GetPage(name: '/employee_dashboard', page: () => EmployeeDashboard()),
  GetPage(name: '/item_management', page: () => ItemManagementScreen()),
  GetPage(name: '/menu', page: () => MenuScreen()),
  GetPage(name: '/cart', page: () => CartScreen()),
  GetPage(name: '/sales_history', page: () => SalesHistoryScreen()),
  GetPage(name: '/transaction_details', page: () => TransactionDetailsScreen()),
  GetPage(name: '/about', page: () => AboutAppScreen()),
  GetPage(name: '/user', page: () => UserPage()),
  GetPage(name: '/register', page: () => RegistrationPage()),
  GetPage(name: '/profile', page: () => ProfileScreen()),
  GetPage(name: '/forgot-password', page: () => ForgotPasswordPage()),
  GetPage(name: '/reset-password', page: () => ResetPasswordPage()),
];
